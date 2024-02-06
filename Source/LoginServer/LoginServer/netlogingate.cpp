/*


	FLD_SECEDE ��  Y �̸� Ż��
*/
#include "netlogingate.h"
#include "loginsvrwnd.h"
#include "../common/mir2packet.h"
#include <stringex.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

// Update Log...2003/01/08 COPark
// ClientVersion Check�� ���� ���� ��ȣ ����
#define VERSION_NUMBER	20050501
//#define VERSION_NUMBER	20030805

static struct sLoginGateCmdList
{
	int  nPacketID;
	bool (CLoginGate:: *pfn)( sGateUser *pUser, char *pBody, _TDEFAULTMESSAGE msg  );
} g_cmdList[] = 
{
	CM_IDPASSWORD,		&CLoginGate::OnIdPassword,
	CM_SELECTSERVER,	&CLoginGate::OnSelectServer,
	CM_PROTOCOL,        &CLoginGate::OnProtocol,
};


static const int g_nCmdCnt = sizeof( g_cmdList ) / sizeof( g_cmdList[0] );


CLoginGate::CLoginGate( SOCKET sdClient, sTblPubIP *pGateInfo )
{
	SetClassId( CLASSID );
	SetAcceptedSocket( sdClient );
	
	m_dbInfo			= *pGateInfo;	
	m_nCntInvalidPacket	= 0;

	m_listUser.InitHashTable( MAX_GATEUSER_HASHSIZE, IHT_ROUNDUP );
	m_listUser.SetGetKeyFunction( __cbGetUserKey );
}


CLoginGate::~CLoginGate()
{
	m_listUser.UninitHashTable();
}


bool CLoginGate::SendKickUser( sGateUser *pUser )
{
	CMir2Packet *pPacket = new CMir2Packet;
	pPacket->Attach( "%+-" );
	pPacket->Attach( pUser->szUserHandle );
	pPacket->Attach( "$" );

	Lock();
	bool bRet = Send( pPacket );
	Unlock();

	return bRet;
}


bool CLoginGate::SendResponse( sGateUser *pUser,
							   int nPacketID, 
							   int nRecog, int nParam, int nTag, int nSeries, char *pData )
{
	_TDEFAULTMESSAGE defMsg;
	fnMakeDefMessage( &defMsg, nPacketID, nRecog, nParam, nTag, nSeries );

	CMir2Packet *pPacket = new  CMir2Packet;
	pPacket->Attach( "%" );
	pPacket->Attach( pUser->szUserHandle );
	pPacket->Attach( "/#" );
	pPacket->AttachWithEncoding( (char *) &defMsg, sizeof( defMsg ) );

	if ( pData )
		pPacket->AttachWithEncoding( pData, strlen( pData ) );

/*	if ( pPacket )
		pPacket->AttachWithEncoding( pData, strlen( pData ) );*/
	pPacket->Attach( "!$" );

#ifdef _DEBUG
	GetApp()->SetLog( 0, "[LoginGate/Send] %s", pPacket->m_pPacket);
#endif
	
	Lock();
	bool bRet = Send( pPacket );
	Unlock();

	return bRet;
}


/*
	CM_IDPASSWORD
*/
bool CLoginGate::OnIdPassword( sGateUser *pUser, char *pBody, _TDEFAULTMESSAGE msg )
{
	// 2003/02/18 �߰��Ⱥκ� (NotInServerMode : ȸ�� IP�� ���)
//	if(GetLoginServer()->m_IsNotInServiceMode && strcmp( pUser->szAddr , "211.214.89.250" )!=0)	 // 218.144.171.253"
//	if( GetLoginServer()->m_IsNotInServiceMode && strcmp( pUser->szAddr, "222.110.172.250" ) != 0 && strcmp( pUser->szAddr, "222.110.172.249" ) != 0 )
	if( GetLoginServer()->m_IsNotInServiceMode && strcmp( pUser->szAddr, "222.110.172.250" ) != 0 )
	{
		SendResponse( pUser, SM_NOT_IN_SERVICE, 0, 0, 0, 0 );
		return false;
	}

	CConnection *pConn = GetLoginServer()->m_dbPool.Alloc();
	if ( !pConn )
	{
		SendResponse( pUser, SM_NOT_IN_SERVICE, 0, 0, 0, 0 );
		return false;
	}
	CConnection *pConnPC = GetLoginServer()->m_dbPoolPC.Alloc();
	if ( !pConnPC )
	{
		SendResponse( pUser, SM_NOT_IN_SERVICE, 0, 0, 0, 0 );
		return false;
	}
	bstr szID, szPW;
	_pickstring( pBody, '/', 0, &szID );
	_pickstring( pBody, '/', 1, &szPW );

	//------------------------------------
	// Query Warning(sonmg 2005/06/16)
	//�� ���ڿ� üũ(LoginSvr)
	if( strlen(szID) > 20 )
		GetApp()->SetLog( CERR, "[LONG-QUERY MESSAGE!!!] %s", szID );
	//------------------------------------

	strcpy( pUser->szID, szID );
	pUser->nClientVersion = msg.nRecog;

	/*
		nPacketRecog

		 0	����
		-1	�н����� Ʋ��
		-2	�н����带 5ȸ ���� �� 10���� ������ �ʾ���
		-3	���� ���̵� ����
		-4
		-5	���̵� ������
		-6	���̵� ����
		-7  �̸�2���̵�.
		-8  ��� ������ ���� �ʰ�
		-9	�ֹε�Ϲ�ȣ ����
		-10 14�� �̸� �θ��Ǽ� �ʿ� 
	*/
	int  nPacketRecog = 0;
	int  nPacketParam = 0;
	bool bNeedUpdate = false;
	bool bAvailableSsn = false;    //�ùٸ��� 15���̻����� �����ϴ� ����
	char szQuery[1024];
	char cFinished[10];

	SYSTEMTIME st;
    GetLocalTime(&st);	//GetSystemTime
	unsigned int nCurrentTime = GetDay(st.wYear, st.wMonth, st.wDay);

	sprintf( szQuery, "SELECT t1.*, t2.* FROM TBL_ACCOUNT t1 LEFT JOIN TBL_ACCOUNTADD t2 ON t1.FLD_LOGINID = t2.FLD_LOGINID WHERE t1.FLD_LOGINID ='%s'", pUser->szID );
#ifdef _DEBUG
	GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
#endif

	pUser->dwMValidFrom		= 0;
	pUser->dwMValidUntil	= 0;
	pUser->dwMSeconds		= 0;
	pUser->dwMStopUntil	    = 0;
	pUser->dwValidFrom		= 0;
	pUser->dwValidUntil		= 0;
	pUser->dwSeconds		= 0;
	pUser->dwStopUntil		= 0;
	pUser->dwIpValidFrom	= 0;
	pUser->dwIpValidUntil	= 0;
	pUser->dwIpSeconds		= -200000;
	pUser->dwIpMValidFrom	= 0;
	pUser->dwIpMValidUntil	= 0;
	pUser->dwIpMSeconds		= 0;
	pUser->nParentCheck		= 0;

	///////////////////////////////////////
	pUser->dwFreeValidFrom		= 0;
	pUser->dwFreeValidUntil		= 0;
	pUser->dwFreeMValidFrom		= 0;
	pUser->dwFreeMValidUntil	= 0;

	pUser->dwFreeSeconds		= 0;
	pUser->dwFreeMSeconds		= 0;
	///////////////////////////////////////

	//�α��� ���̵� üũ
	CRecordset *pRec = pConn->CreateRecordset();
	if ( !pRec->Execute( szQuery ) || !pRec->Fetch() )
	{
		nPacketRecog = -6;
		pConn->DestroyRecordset( pRec );
		SendResponse( pUser, SM_PASSWD_FAIL, nPacketRecog, 0, 0, 0 );

		#ifdef _DEBUG
			GetApp()->SetLog( 0, "[LoginGate/ Send] SM_PASSWD_FAIL : %d",nPacketRecog);
		#endif

	}
	else
	{
		pUser->nPassFailCount	= atoi( pRec->Get( "FLD_PASSFAILCOUNT" ) );
		pUser->nPassFailTime	= atoi( pRec->Get( "FLD_PASSFAILTIME" ) );

		//-----------------------------------------------------	
		// 2003/04/09 Ż��ȸ�� ó�� �߰�
		memset(cFinished, 0, sizeof(cFinished));
		strcpy(cFinished , pRec->Get("FLD_SECEDE"));
		if (cFinished[0] == 'Y' || cFinished[0] == 'y')
		{
			nPacketRecog = -6;
#ifdef _DEBUG
			GetApp()->SetLog( 0, "%s:Closed User", pUser->szID);
#endif
		}


		//15���̸� �� �ֹι�ȣ üũ �߰��Ⱥκ�
		//-----------------------------------------------------	
		strcpy(pUser->szSsno , pRec->Get("FLD_SSNO"));
		_trim(pUser->szSsno);
	
		if(!isCorrectSsn(pUser->szSsno))
		{
//			nPacketRecog = -9;
			bAvailableSsn = false;
#ifdef _DEBUG
			GetApp()->SetLog( 0, "%s is not correst ssn", pUser->szSsno);
#endif
		}
		else
		{
//			if(isOlderthen15(pUser->szSsno))
//			{
				bAvailableSsn = true;
//			}
//			else
//			{
//				bAvailableSsn = false;
//			}
		}
		//-----------------------------------------------------
		pUser->nParentCheck		= atoi(pRec->Get("FLD_PCHECK"));
		if ( pUser->nParentCheck == 3 )
		{
			nPacketRecog = -10;
#ifdef _DEBUG
			GetApp()->SetLog( 0, "%s:ParentCheck is 3", pUser->szID);
#endif
		}
		
		//-----------------------------------------------------
		pUser->dwValidFrom		= GetTimeInfo(pRec->Get("FLD_VALIDFROM"));
		pUser->dwValidUntil		= GetTimeInfo(pRec->Get("FLD_VALIDUNTIL"));
		pUser->dwSeconds		= atoi(pRec->Get("FLD_SECONDS"));
		pUser->dwStopUntil		= GetTimeInfo( pRec->Get( "FLD_STOPUNTIL" ) );

		//Free
//		pUser->dwFreeValidFrom		= GetTimeInfo(pRec->Get("FLD_FreeVALIDFROM"));
		pUser->dwFreeValidUntil		= GetTimeInfo(pRec->Get("FLD_FreeVALIDUNTIL"));
		pUser->dwFreeSeconds		= atoi(pRec->Get("FLD_FreeSECONDS"));


		if(strcmp(GetLoginServer()->m_szGameType, "MIR2") ==0)
		{
			pUser->dwMValidFrom		= GetTimeInfo(pRec->Get("FLD_M2VALIDFROM"));
			pUser->dwMValidUntil	= GetTimeInfo(pRec->Get("FLD_M2VALIDUNTIL"));
			pUser->dwMSeconds		= atoi(pRec->Get("FLD_M2SECONDS"));
			pUser->dwMStopUntil	    = GetTimeInfo(pRec->Get("FLD_M2STOPUNTIL"));

			//Free
//			pUser->dwFreeMValidFrom		= GetTimeInfo(pRec->Get("FLD_FreeM2VALIDFROM"));
			pUser->dwFreeMValidUntil	= GetTimeInfo(pRec->Get("FLD_FreeM2VALIDUNTIL"));
			pUser->dwFreeMSeconds		= atoi(pRec->Get("FLD_FreeM2SECONDS"));
		}

		if(strcmp(GetLoginServer()->m_szGameType, "MIR3") ==0)
		{
			pUser->dwMValidFrom		= GetTimeInfo(pRec->Get("FLD_M3VALIDFROM"));
			pUser->dwMValidUntil	= GetTimeInfo(pRec->Get("FLD_M3VALIDUNTIL"));
			pUser->dwMSeconds		= atoi(pRec->Get("FLD_M3SECONDS"));
			pUser->dwMStopUntil	= GetTimeInfo(pRec->Get("FLD_M3STOPUNTIL"));

			//Free
//			pUser->dwFreeMValidFrom		= GetTimeInfo(pRec->Get("FLD_FreeM3VALIDFROM"));
			pUser->dwFreeMValidUntil	= GetTimeInfo(pRec->Get("FLD_FreeM3VALIDUNTIL"));
			pUser->dwFreeMSeconds		= atoi(pRec->Get("FLD_FreeM3SECONDS"));
		}

		// ȸ�� IP Ȯ��(ȸ�翡���� ���� ĳ�� ���� ���)
//		if(strcmp( pUser->szAddr , "211.214.89.250")==0)	// 218.144.171.253
//		if( strcmp( pUser->szAddr, "222.110.172.250") == 0 || strcmp( pUser->szAddr, "222.110.172.249") == 0 )
		if( strcmp( pUser->szAddr, "222.110.172.250") == 0 )
		{
			pUser->dwStopUntil		= 0;
			pUser->dwMStopUntil		= 0;
		}

		pUser->dwMakeTime		= GetTimeInfo( pRec->Get( "FLD_MAKETIME" ) );
		int nVersion            = atoi( pRec->Get("FLD_VER"));
		bstr szDBPW				= pRec->Get( "FLD_PASSWORD" );
		pConn->DestroyRecordset( pRec );

		//�����Ⱓ üũ
		if ( (pUser->dwStopUntil > nCurrentTime ) ||( pUser->dwMStopUntil > nCurrentTime )  )
		{
			nPacketRecog = -5;
			nPacketParam = ( pUser->dwMStopUntil - nCurrentTime );
			if( nPacketParam <= 0 ) nPacketParam = ( pUser->dwStopUntil - nCurrentTime );
		}
		else
		{
			//��й�ȣƲ�� �ð� �� Ƚ��üũ
			if ( pUser->nPassFailCount >= 3 || GetTickCount() - pUser->nPassFailTime < 60000 )
			{
				nPacketRecog = -2;
				pUser->nPassFailCount  =0;
				//pUser->nPassFailTime = GetTickCount();				
			}
			else
			{
				_trim( szPW ); 
				_trim( szDBPW );

				if ( szPW != szDBPW )
				{
					nPacketRecog = -1;
					pUser->nPassFailCount++;
					if (pUser->nPassFailCount >=3)
						pUser->nPassFailTime = GetTickCount();
				}
				else
				{
					pUser->nPassFailCount = 0;
					pUser->nPassFailTime  = 0;

					/*if ( strlen( szDBName ) == 0 )
						bNeedUpdate = true;*/
				}
			}
			pRec = pConn->CreateRecordset();
			sprintf( szQuery, 
					 "UPDATE TBL_ACCOUNT SET FLD_PASSFAILCOUNT = %d, FLD_PASSFAILTIME = %d "
					 "WHERE FLD_LOGINID='%s'",
					 pUser->nPassFailCount, pUser->nPassFailTime, pUser->szID );
#ifdef _DEBUG
			GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
#endif
			pRec->Execute( szQuery );
			pConn->DestroyRecordset( pRec );
		}



		if ( nPacketRecog == 0 )
		{
			GetLoginServer()->m_csListCert.Lock();
			sCertUser *psCertUser = GetLoginServer()->m_listCert.SearchKey( pUser->szID );

			if (psCertUser)
			//if ( GetLoginServer()->m_listCert.SearchKey( pUser->szID ) )
			{
				nPacketRecog = -3;
				/*	FILE *fp = fopen( "d:\\Admission.txt", "ab" );
					fprintf( fp, "CLoginGate::OnIdPassword\r\n" );
					fclose( fp );*/

				GetLoginServer()->SendCancelAdmissionUser( psCertUser );
				psCertUser->bClosing = true;
				if (!psCertUser->bClosing)
					psCertUser->nOpenTime = GetTickCount();
			}
			GetLoginServer()->m_csListCert.Unlock();
		}

		/*if ( bNeedUpdate )
			SendResponse( pUser, SM_NEEDUPDATE_ACCOUNT, 0, 0, 0, 0 );
		if(nVersion==0)
			nPacketRecog =-7;*/

		if ( nPacketRecog == 0 )
		{
			pUser->bSelServerOK		= false;
			pUser->nCertification	= GetCertification();
			int nPCBangIndex = 0;
			int nPCBangMaxCount = 0;
			int nPCBangCurrent = 0;

			sprintf( szQuery, "SELECT * FROM MR3_IPTable A, MR3_PCRoomStatusTable B WHERE A.IP_PCRoomIndex = B.PCRoomStatus_PCRoomIndex AND A.IP_Address = '%s'", pUser->szAddr );
//			sprintf( szQuery, "SELECT * FROM TBL_IPACCOUNT A, TBL_PCBANG B WHERE A.FLD_PCBANGINDEX = B.FLD_PCBANGINDEX AND A.FLD_IP = '%s'", pUser->szAddr );
#ifdef _DEBUG
			GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
#endif
			pRec = pConnPC->CreateRecordset();
			if (pRec) 
			{
				pRec->Execute( szQuery );
				if ( pRec->Fetch() )
				{
	//				GetApp()->SetLog( 0, "[SQL Execute OK] Fetch....");
					//���ӹ� ���װ���
					char sztemp[30];
					strcpy(sztemp,pRec->Get( "PCRoomStatus_FromDate" )); 
					pUser->dwIpValidFrom	= GetTimeInfo( pRec->Get( "PCRoomStatus_FromDate" ) );
					strcpy(sztemp,pRec->Get( "PCRoomStatus_RemainedDay" ));
					pUser->dwIpValidUntil	= GetTimeInfo( pRec->Get( "PCRoomStatus_RemainedDay" ) );

					pUser->dwIpSeconds		= atoi( pRec->Get( "PCRoomStatus_RemainedTime" ) );
					nPCBangIndex			= atoi( pRec->Get( "IP_PCRoomIndex" ) );
					nPCBangMaxCount			= atoi( pRec->Get( "PCRoomStatus_IPCount" ) );
					nPCBangCurrent			= atoi( pRec->Get( "PCRoomStatus_UsingIPCount" ) );

					if(strcmp(GetLoginServer()->m_szGameType, "MIR2") ==0)
					{
						pUser->dwIpMValidFrom	= GetTimeInfo( pRec->Get( "PCRoomStatus_M2FromDate" ) );
						pUser->dwIpMValidUntil	= GetTimeInfo( pRec->Get( "PCRoomStatus_M2RemainedDay" ) );
						pUser->dwIpMSeconds		= atoi( pRec->Get( "PCRoomStatus_M2RemainedTime" ) );;
					}
					if(strcmp(GetLoginServer()->m_szGameType, "MIR3") ==0)
					{
						pUser->dwIpMValidFrom	= GetTimeInfo( pRec->Get( "PCRoomStatus_M3FromDate" ) );
						pUser->dwIpMValidUntil	= GetTimeInfo( pRec->Get( "PCRoomStatus_M3RemainedDay" ) );
						pUser->dwIpMSeconds		= atoi( pRec->Get( "PCRoomStatus_M3RemainedTime" ) );
					} 
					
					/* 2003/02/03 �ߺ� ������ üũ
					//���ӹ��̹Ƿ�  �Ʒ� ���� üũ
					
					//1. �ߺ� IP üũ
					//	 TBL_USINGIP�� �ִ��� Ȯ��, ������ �Ʒ� 2������ ����
					//	 ������ ���� ����Ÿ������ Ȯ��, ������ KICK ��û�� ���� ���� 
					//	 ���� ������ TBL_DUPIP�� ����Ͽ� KICK ��û, 2������ ����
					sprintf( szQuery, "SELECT * FROM TBL_USINGIP WHERE FLD_USINGIP = '%s' AND FLD_GAMETYPE = '%s'", pUser->szAddr, GetLoginServer()->m_szGameType);
	#ifdef _DEBUG
					GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
	#endif
					CRecordset *pRec2 = pConnPC->CreateRecordset();
					if ( pRec2->Execute( szQuery ) && pRec2->Fetch() )
					{
						// ��������� �Ǿ� �ִٸ� ���� ������ ��� KICK ó��, �ƴϸ� TBL_DUPIP�� ���
						if(strcmp(GetLoginServer()->m_szGameType, pRec2->Get( "FLD_GAMETYPE" )) ==0)
						{
							GetLoginServer()->m_csListCert.Lock();
							sCertUser *psCertUser = GetLoginServer()->m_listCert.SearchKey( pRec2->Get( "FLD_USERID" ) );

							if (psCertUser)
							{
								nPacketRecog = -3;
								//	FILE *fp = fopen( "d:\\Admission.txt", "ab" );
								//	fprintf( fp, "CLoginGate::OnIdPassword\r\n" );
								//	fclose( fp );

								GetLoginServer()->SendCancelAdmissionUser( psCertUser );
								psCertUser->bClosing = true;
								if (!psCertUser->bClosing)
									psCertUser->nOpenTime = GetTickCount();
							}
							GetLoginServer()->m_csListCert.Unlock();
							pConnPC->DestroyRecordset( pRec2 );
						}
						// ���� ������ �ƴϹǷ� ��� ����Ͽ� ű�� ��û
						else
						{
							pConnPC->DestroyRecordset( pRec2 );
							// Write TBL_DUPIP
							sprintf( szQuery, "INSERT INTO TBL_DUPIP (FLD_IP, FLD_GAMETYPE, FLD_PCBANG, FLD_ISOK, FLD_REQUEST) VALUES ('%s', 'MIR3', %d, '0', GetDate())", pUser->szAddr, nPCBangIndex );
	#ifdef _DEBUG
							GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
	#endif
							pRec2 = pConnPC->CreateRecordset();
							pRec2->Execute( szQuery );
							pConnPC->DestroyRecordset( pRec2 );
						}
					}
					//2. ���� ��� IP������ MAX�������� ������ Ȯ��
					//���� ��� OK, TBL_USINGIP�� IP�߰�
					//ũ�ų� ���� ��� FAIL, ���� ��� IP������ ���ٰ� �����ڵ� ����
					if ( nPacketRecog == 0 )
					{
						if( nPCBangCurrent >= nPCBangMaxCount )
						{
							nPacketRecog = -8;
						}
						else
						{
							// Write TBL_USINGIP
							sprintf( szQuery, "INSERT INTO TBL_USINGIP (FLD_PCBANG, FLD_USINGIP, FLD_GAMETYPE, FLD_FROM, FLD_SERVER, FLD_USERID ) VALUES (%d, '%s', '%s', GetDate(), '%d', '%s')", nPCBangIndex, pUser->szAddr, GetLoginServer()->m_szGameType, pUser->nServerID, pUser->szID );
	#ifdef _DEBUG
							GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
	#endif
							pRec2 = pConnPC->CreateRecordset();
							pRec2->Execute( szQuery );
							pConnPC->DestroyRecordset( pRec2 );
							// ������� IP Count ����
							nPCBangCurrent++;
							sprintf( szQuery, "UPDATE MR3_PCRoomStatusTable SET PCRoomStatus_UsingIPCount = %d WHERE PCRoomStatus_PCRoomIndex = %d", nPCBangCurrent, nPCBangIndex );
	#ifdef _DEBUG
							GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
	#endif
							pRec2 = pConnPC->CreateRecordset();
							pRec2->Execute( szQuery );
							pConnPC->DestroyRecordset( pRec2 );
						}
					}
					*/
				}
			}
			pConnPC->DestroyRecordset( pRec );
			pUser->nPayMode = 0;
			
			//nPaymode => 0 : ü����, 1 : ����, 2 : ����(������ �Ⱓ)

			
			//������������ üũ 
			//�ش�����
			//����

			if( ((nCurrentTime >= pUser->dwValidFrom )    && (nCurrentTime <= pUser->dwValidUntil )) ||			//����		����	���׿� �ش��ϴ°��.
				((nCurrentTime >= pUser->dwMValidFrom )   && (nCurrentTime <= pUser->dwMValidUntil ))||			//����				���׿� �ش��ϴ� ���
			    ((nCurrentTime >= pUser->dwIpValidFrom )  && (nCurrentTime <= pUser->dwIpValidUntil )) ||		//���ӹ�	����	���׿� �ش��ϴ� ���
				((nCurrentTime >= pUser->dwIpMValidFrom ) && (nCurrentTime <= pUser->dwIpMValidUntil ))||		//���ӹ�			���׿� �ش� �ϴ� ���
				((nCurrentTime >= pUser->dwFreeValidFrom )    && (nCurrentTime <= pUser->dwFreeValidUntil )) ||		//���� ���� ���� ���׿� �ش��ϴ°��.
				((nCurrentTime >= pUser->dwFreeMValidFrom )   && (nCurrentTime <= pUser->dwFreeMValidUntil ))||		//���� ����	���׿� �ش��ϴ� ���
				(pUser->dwSeconds > 0) ||																		//����		����	������ �ش��ϴ� ���
				(pUser->dwMSeconds > 0 )||																		//����				������ �ش��ϴ� ���
				(pUser->dwIpSeconds > -180000) ||																	//���ӹ� -50�ð� ����	
				(pUser->dwFreeSeconds > 0) ||																		//���� ���� ���� ������ �ش��ϴ� ���
				(pUser->dwFreeMSeconds > 0 ))																		//���� ���� ������ �ش��ϴ� ���
//				(pUser->dwSeconds + pUser->dwIpSeconds + pUser->dwIpMSeconds + pUser->dwMSeconds > 0))
			{
				pUser->nPayMode = 1;
				// ���� ���� (����) : ���� ��¥ ǥ�� ��� ����...
				if(pUser->dwValidUntil ==0)
					pUser->dwValidUntil = nCurrentTime;
				else //if(pUser->dwValidUntil ==nCurrentTime)
					pUser->dwValidUntil++;

#ifdef _DEBUG
			GetApp()->SetLog(0,"[Check1] dwValidUntil: %d, CurTime: %d", pUser->dwValidUntil, nCurrentTime );
#endif	

				if(pUser->dwMValidUntil ==0)
					pUser->dwMValidUntil = nCurrentTime;
				else if(pUser->dwMValidUntil ==nCurrentTime)
					pUser->dwMValidUntil++;
#ifdef _DEBUG
			GetApp()->SetLog(0,"[Check2] dwMValidUntil: %d, CurTime: %d", pUser->dwMValidUntil, nCurrentTime );
#endif	

				// ���� ���� ����(2004/06/07) (����) : ���� ��¥ ǥ�� ��� ����...
				if(pUser->dwFreeValidUntil ==0)
					pUser->dwFreeValidUntil = nCurrentTime;
				else //if(pUser->dwFreeValidUntil ==nCurrentTime)
					pUser->dwFreeValidUntil++;
#ifdef _DEBUG
			GetApp()->SetLog(0,"[Check3] dwFreeValidUntil: %d, CurTime: %d", pUser->dwFreeValidUntil, nCurrentTime );
#endif	

				if(pUser->dwFreeMValidUntil ==0)
					pUser->dwFreeMValidUntil = nCurrentTime;
				else //if(pUser->dwFreeMValidUntil ==nCurrentTime)
					pUser->dwFreeMValidUntil++;
#ifdef _DEBUG
			GetApp()->SetLog(0,"[Check4] dwFreeMValidUntil: %d, CurTime: %d", pUser->dwFreeMValidUntil, nCurrentTime );
#endif	

				// �Ǿ��� ���� (����) : ���� ��¥ ǥ�� ��� ����...
				if(pUser->dwIpValidUntil ==0)
					pUser->dwIpValidUntil = nCurrentTime;
				else //if(pUser->dwIpValidUntil ==nCurrentTime)
					pUser->dwIpValidUntil++;

				if(pUser->dwIpMValidUntil ==0)
					pUser->dwIpMValidUntil = nCurrentTime;
				else //if(pUser->dwIpMValidUntil ==nCurrentTime)
					pUser->dwIpMValidUntil++;

				long RemainDays		= 0;
				long RemainM2Days	= 0;
				long RemainFreeDays		= 0;
				long RemainFreeM2Days	= 0;
				long RemainIpDays	= 0;
				long RemainHours	= 0;
				long RemainM2Hours	= 0;
				long RemainFreeHours	= 0;
				long RemainFreeM2Hours	= 0;
				long RemainIpHours	= 0;

				RemainDays    = pUser->dwValidUntil - nCurrentTime;
				RemainM2Days  = pUser->dwMValidUntil - nCurrentTime;
				RemainFreeDays    = pUser->dwFreeValidUntil - nCurrentTime;
				RemainFreeM2Days  = pUser->dwFreeMValidUntil - nCurrentTime;
				RemainIpDays  = pUser->dwIpValidUntil - nCurrentTime;
				RemainHours   = (pUser->dwSeconds + 1) / 3600;
				RemainM2Hours   = (pUser->dwMSeconds + 1) / 3600;
				RemainFreeHours   = (pUser->dwFreeSeconds + 1) / 3600;
				RemainFreeM2Hours   = (pUser->dwFreeMSeconds + 1) / 3600;
				RemainIpHours = (pUser->dwIpSeconds + 1) / 3600;

				if(RemainDays < 0)    RemainDays    = 0;
				if(RemainM2Days < 0)  RemainM2Days  = 0;
				if(RemainFreeDays < 0)    RemainFreeDays    = 0;
				if(RemainFreeM2Days < 0)  RemainFreeM2Days  = 0;
				if(RemainIpDays < 0)  RemainIpDays  = 0;
				if(RemainHours < 0)   RemainHours   = 0;
				if(RemainM2Hours < 0)   RemainM2Hours   = 0;
				if(RemainFreeHours < 0)   RemainFreeHours   = 0;
				if(RemainFreeM2Hours < 0)   RemainFreeM2Hours   = 0;
				if(RemainIpHours < 0) RemainIpHours = 0;

				//�������� vs ����Mir2 �߿� ū �� ����.
				if(RemainM2Days > RemainDays)
					RemainDays = RemainM2Days;

				//(�������� vs ����Mir2 �߿� ū ��) vs �������� �߿� ū�� ����.
				if(RemainFreeDays > RemainDays)
					RemainDays = RemainFreeDays;

				//((�������� vs ����Mir2 �߿� ū ��) vs ��������) vs ����Mir2 �߿� ū�� ����.
				if(RemainFreeM2Days > RemainDays)
					RemainDays = RemainFreeM2Days;

				//���� ������ ������...
				if( RemainDays == 0 )
				{
					//���� Mir2���� �ִ´�.
					RemainDays = RemainFreeM2Days;
					if( RemainDays == 0 )
					{
						//���� Mir2�뵵 ������ ���� ���� ������ �ִ´�.
						RemainDays = RemainFreeDays;
					}

				}

				// ���� �����ð��� Mir2������ �����ش�.
				RemainHours = RemainHours + RemainM2Hours;
				// ���� �����ð��� Mir2���������� �����ش�.
				RemainFreeHours = RemainFreeHours + RemainFreeM2Hours;
				// ���� ������ ������...
				if( RemainHours == 0 )
				{
					// ���� ������ �ִ´�.
					RemainHours = RemainFreeHours;
				}
				else
				{
					// �������� + ����Mir2 + �������� + ����Mir2
					RemainHours = RemainHours + RemainFreeHours;
				}

				//-50�ð� ����   -50�ð� = 50 * 3600 = 180,000
				if(pUser->dwIpSeconds > -180000 && RemainIpHours == 0)
				{
					RemainIpHours = 1;
				}

				//Ʋ�� �ֹι�ȣ �Ǵ� 15���̸��ΰ�� �߰��� �޼��� ����
				// SM_PASSOK_WRONGSSN = 534
				if(!bAvailableSsn) 
				{
//					SendResponse( pUser, SM_PASSOK_WRONGSSN,0,0,0,0);
				}

				SendResponse( pUser, SM_PASSOK_SELECTSERVER, 
							  MAKELONG((WORD)(RemainDays), (WORD)(RemainHours)), 
							  RemainIpDays,
							  RemainIpHours,
							  0);

//						GetApp()->SetLog( 0, "[SQL QUERY] %02x %02x %02x %02x (%04x) ", 
//						  	  (WORD)(RemainDays),
//							  pUser->dwSeconds,
//							  RemainIpDays,
//							  pUser->dwIpSeconds,
//							  MAKELONG((WORD)(RemainDays), (WORD)(pUser->dwSeconds))
//							);
			}
			else
			{
				if(!bAvailableSsn) 
				{
//					SendResponse( pUser, SM_PASSOK_WRONGSSN,0,0,0,0);
				}
				pUser->nPayMode = 0;
				SendResponse( pUser, SM_PASSOK_SELECTSERVER, 0, 0, 0, 0 );
			}


#ifdef _DEBUG
			GetApp()->SetLog(0,"[LoginGate/Send] SM_PASSOK_SELECTSERVER : %s", pUser->szID );
#endif	

			GetLoginServer()->AddCertUser( pUser );
			GetLoginServer()->WriteConLog(pUser->szID , pUser->szAddr);

			//�α��ν� ���̵�üũ�� �޼��� ������
			if (GetLoginServer()->CheckBadAccount(pUser->szID))
			{
				char message[1024];
				sprintf(message, "%d-%d-%d %d:%d %d ���Ӿ��̵� %s��(��)  %s���� ������ �õ��߽��ϴ�.[%s]", st.wYear,st.wMonth,st.wDay, st.wHour, st.wMinute, st.wSecond, pUser->szID, pUser->szAddr, GetLoginServer()->m_szGameType);
				GetLoginServer()->m_udpSender.SendMessages(message);

			}
		}
		else{
			SendResponse( pUser, SM_PASSWD_FAIL, nPacketRecog, nPacketParam, 0, 0 );
#ifdef _DEBUG
			GetApp()->SetLog(0,"[LoginGate/Send] SM_PASSWD_FAIL : %d", nPacketRecog);
#endif	
		}
	}
	
	GetLoginServer()->m_dbPoolPC.Free( pConnPC );
	GetLoginServer()->m_dbPool.Free( pConn );
	return true;
}


/*
	CM_SELECTSERVER
*/

bool CLoginGate::OnSelectServer( sGateUser *pUser, char *pBody, _TDEFAULTMESSAGE msg )
{
	if ( strlen( pUser->szID ) == 0 )
	{
		SendKickUser( pUser );
		delete m_listUser.Remove( pUser );	//sonmg 2005/01/31
		return false;
	}

	pUser->bSelServerOK = true;
	
	char szServerName[32] = {0,};
	strcpy(szServerName, pBody);
	//fnDecode6BitBuf( pBody, szServerName, sizeof( szServerName ) );
	
	pUser->bFreeMode = false;	
	

	SYSTEMTIME st;
    GetLocalTime(&st);	//GetSystemTime
	int nCurrentTime = GetDay(st.wYear, st.wMonth, st.wDay);

/*
	if ( nCurrentTime - pUser->dwMakeTime < GetLoginServer()->m_nFreePeriods * 60 * 60 * 24 )
	{
		pUser->nPayMode = 2;
		pUser->bFreeMode = true;
	}
*/	
	//
	// ������ ���� seek
	//
	CGameServer *pGameServer = NULL;
	CGameServerInfo *pSelectServerInfo = NULL;
	sTblSelectGateIP	*pSelectGate = NULL;
	
	CListNode<CGameServerInfo> *pServerNode = GetLoginServer()->m_listServerInfo.GetHead();
	for(; pServerNode;pServerNode = pServerNode->GetNext())
	{
		CGameServerInfo *pServerInfo = pServerNode->GetData();
		if(strcmp(pServerInfo->szName, szServerName) == 0)
		{
			pSelectServerInfo = pServerInfo;
			pSelectGate = pServerInfo->GetSelectGate();
			if(pServerInfo->nFreemode == 0)
				pUser->bFreeMode = false;//true;	// fixed by sonmg(2005/03/29)
			break;
		}
	}
	
	if (!pSelectGate||
		(pSelectServerInfo->nMaxUserCount < GetLoginServer()->RecalUserCount(szServerName)))
	{
		GetLoginServer()->DelCertUser( pUser );
		SendResponse( pUser, SM_STARTFAIL, 0, 0, 0, 0 );
		
		return false;
	}
	
	
	GetLoginServer()->m_csListCert.Lock();
	sCertUser *pCert = GetLoginServer()->m_listCert.SearchKey( pUser->szID );
	if ( pCert )
	{
		strcpy( pCert->szServerName, szServerName );
		pCert->bFreeMode = pUser->bFreeMode;
	}
	GetLoginServer()->m_csListCert.Unlock();
	
	CListNode< CGameServer > *pNode;

	GetLoginServer()->m_listGameServer.Lock();

	// EXLOG
	int __CNT1 = 0;
	int __CNT2 = 0;

	pNode = GetLoginServer()->m_listGameServer.GetHead();
	for (pNode = GetLoginServer()->m_listGameServer.GetHead(); pNode; pNode = pNode->GetNext() )
	{
		CGameServer *pObj = pNode->GetData();

		if(pObj){
			if(stricmp(pObj->m_dbInfo.szName , szServerName)==0)
			{
				if(!pObj->SendPasswordSuccess( pUser ))
				{
#ifdef _DEBUG
					GetApp()->SetLog(0,"[SendPasswordFail]");
#endif
					__CNT2++;
				}

				__CNT1++;
			}

		}
		
	}	
	GetLoginServer()->m_listGameServer.Unlock();

/*	FILE *fp = fopen( "d:\\Admission.txt", "ab" );
	fprintf( fp, "==> Result: %d %d\r\n\r\n", __CNT1, __CNT2 );
	fclose( fp );*/

	//
	// ���� �޽��� send
	//
	char szText[1024];
	sprintf( szText, 
			 "%s/%d/%d", 
			 pSelectGate->szIP, pSelectGate->nPort, pUser->nCertification );
	SendResponse( pUser, SM_SELECTSERVER_OK, pUser->nCertification, 0, 0, 0, szText );

	return true;
}


/*
	KeepAlive

	%--$
*/
bool CLoginGate::OnKeepAlive()
{
	CMir2Packet *pPacket = new CMir2Packet;
	pPacket->Attach( "%++$" );
	Lock();
	bool bRet = Send( pPacket );
	Unlock();

	return bRet;
}


/*
	User Data

	%A[HANDLE]/#?[DefMsg][Data]!$
*/
bool CLoginGate::OnUserData( char *pBody )
{
	char *pData = strchr( pBody, '/' );
	if ( !pData )
	{
		m_nCntInvalidPacket++;
		return false;
	}
	*pData++ = NULL;

	sGateUser *pUser = m_listUser.SearchKey( pBody );
	if ( !pUser )
	{
		m_nCntInvalidPacket++;
		return false;
	}

	//
	// Relay ��Ŷ ��ȿ�� �˻�
	//
	int nDataLen = strlen( pData );
	if ( pData[0] != '#' || pData[nDataLen - 1] != '!' )
	{
		m_nCntInvalidPacket++;
		return true;
	}	
	pData[nDataLen - 1] = NULL;
	pData += 2;

	//
	// Default Message ���ڵ�
	//
	_TDEFAULTMESSAGE msg;
	fnDecodeMessage( &msg, pData );

	BYTE LeftByte = 0, RightByte = 0;

	switch( msg.wIdent )
	{
	case CM_IDPASSWORD:
//      smsg.Etc := WORD((smsg.Recog and $CD + smsg.Ident or $48 + smsg.Param or $30 + smsg.Tag and $2D + smsg.Series) xor GetPublicKey);
		// old version
//		if( WORD(((msg.nRecog & 0x57CD) + (msg.wIdent | 0x48) + (msg.wParam | 0x30) + (msg.wTag & 0x2D) + msg.wSeries) ^ GetPublicKey()) != msg.wEtc )
		// MAKEWORD( BYTE(((smsg.Recog and $57CD) + (smsg.Ident or $48) + (smsg.Param or $30) + (smsg.Tag and $2D) + smsg.Series) xor GetPublicKey), BYTE(Random(256) xor $08) );
		RightByte = LOBYTE( msg.wEtc ) ^ 0x08;
		LeftByte = BYTE( ((msg.nRecog & 0x57CD) + (msg.wIdent | 0x48) + (msg.wParam | 0x30) + (msg.wTag & 0x2D) + msg.wSeries) ^ (GetPublicKey() ^ RightByte) );
		if( LeftByte != HIBYTE(msg.wEtc) )
			return false;
	}
	
	pData +=  _DEFBLOCKSIZE;

	CDecodedString *pdData = fnDecodeString(pData);

/*
	//-----------------------------------------------------------
	//20040715 �Է�â�� ���� ���� ���� ����
	char *pDataNull = strchr( pdData->m_pData, ' ' );
	if ( pDataNull != NULL )
	{
		GetApp()->SetLog( CERR, "[QUERY WARNING!!!] %s", pdData->m_pData );
		return false;
	}
	//-----------------------------------------------------------
*/

	//ID ����
	bstr szID;
	_pickstring( pdData->m_pData, '/', 0, &szID );

	//-----------------------------------------------------------
	//2005/06/10 - ID�� Ư������ üũ �߰�
	//�� ���ڿ� üũ(LoginSvr)
	if( strlen(szID) > 20 )
		GetApp()->SetLog( CERR, "[LONG-QUERY MESSAGE!!!] %s", pdData->m_pData );

	//Ư�� ���ڰ� �� ������ ���� ����
	char *pDataNull = strchr(szID.ptr, ' ' );
	if ( pDataNull != NULL )
	{
		GetApp()->SetLog( CERR, "[QUERY WARNING!!!] %s", pdData->m_pData );
		return false;
	}
	pDataNull = strchr(szID.ptr, '-' );
	if ( pDataNull != NULL )
	{
		GetApp()->SetLog( CERR, "[QUERY WARNING!!!] %s", pdData->m_pData );
		return false;
	}
	pDataNull = strchr(szID.ptr, '\'' );
	if ( pDataNull != NULL )
	{
		GetApp()->SetLog( CERR, "[QUERY WARNING!!!] %s", pdData->m_pData );
		return false;
	}
	//-----------------------------------------------------------

	//-----------------------------------------------------------
	//�ߺ� ID üũ(sonmg 2004/08/18)
	CListNode< sGateUser > *pNode;
	pNode = m_listUser.GetHead();
	for ( ; pNode; pNode = pNode->GetNext() )
	{
		// ���� �����
		sGateUser *pTempUser = pNode->GetData();
		// ���� ����ڰ� ������...
		if( strcmp(pTempUser->szID, szID) == 0 )
		{
			if( strcmp(pTempUser->szUserHandle, pUser->szUserHandle) != 0 )
			{
				GetApp()->SetLog( CDBG, "[LoginGate/Duplicated User] %s %s[%s] %s[%s]", pTempUser->szID, pUser->szUserHandle, pUser->szAddr, pTempUser->szUserHandle, pTempUser->szAddr );

				//-----------------------------------------------------
				// ������ ���´�.(sonmg 2005/01/21)
				SendKickUser( pUser );
				delete m_listUser.Remove( pUser );	//sonmg 2005/01/31
				SendKickUser( pTempUser );
				//-----------------------------------------------------

				//���� ������ �� �ڽ��� �����Ѵ�.
				if ( !pTempUser->bSelServerOK )
					GetLoginServer()->DelCertUser( pTempUser );

				//�� �ڽŰ� ������ �����Ѵ�.
				delete m_listUser.Remove( pTempUser );
				delete pdData;
				return false;
			}
		}
	}	
	//-----------------------------------------------------------

	//
	// �ش� �������� �Լ��� ȣ���Ѵ�.
	//
	for ( int i = 0; i < g_nCmdCnt; i++ )
	{
		if ( msg.wIdent == g_cmdList[i].nPacketID )
		{
			if ( !(this->*g_cmdList[i].pfn)( pUser, *pdData, msg ) )
			{
#ifdef _EX_DEBUG
				GetApp()->SetLog( CDBG, "����! �α��ΰ���Ʈ ��Ŷ �Լ� ���� ����!! %s %d", __FILE__, __LINE__ );
#endif
			}
			delete pdData;
			return true;
		}
	}

	delete pdData;

	m_nCntInvalidPacket++;
	return false;
}


/*
	User Open

	%O[HANDLE]/[ADDR]$
*/
bool CLoginGate::OnUserOpen( char *pBody )
{
	bstr szHandle, szAddr;
	_pickstring( pBody, '/', 0, &szHandle );
	_pickstring( pBody, '/', 1, &szAddr );

	//
	// �ߺ� Open ó��
	//
	sGateUser *pUser = m_listUser.SearchKey( szHandle );
	if ( pUser )
		return true;

	pUser = new sGateUser;
	memset( pUser, 0, sizeof( sGateUser ) );

	pUser->nGateSocket = m_sdHost;
	strcpy( pUser->szUserHandle, szHandle );
	strcpy( pUser->szAddr, szAddr );

	bool bRet = m_listUser.Insert( pUser );
	
#ifdef _DEBUG
	GetApp()->SetLog( CDBG, "OPEN GATE_USER: %d", m_listUser.GetCount() );
#endif

	// ID�� Password�� ������ PublicKey�� XOR�Ͽ� XOR���� �Բ� Ŭ���̾�Ʈ�� ������.(sonmg 2005/04/21)
	ChangeByDefaultKey();
	SendResponse( pUser, SM_SEND_PUBLICKEY, 0, GetSavedKey() ^ 0xF0E0, 0xF0E0, 0 );
	ChangeBySavedKey();

	return bRet;
}


/*
	User Close

	%X[HANDLE]$
*/
bool CLoginGate::OnUserClose( char *pBody )
{
	char *pHandle = pBody;

	sGateUser *pUser = m_listUser.SearchKey( pHandle );
	if ( !pUser )
		return true;

	if ( !pUser->bSelServerOK )
		GetLoginServer()->DelCertUser( pUser );

	delete m_listUser.Remove( pUser );

#ifdef _DEBUG
	GetApp()->SetLog( CDBG, "CLOSE GATE_USER: %d", m_listUser.GetCount() );
#endif

	return true;
}


void CLoginGate::OnError( int nErrCode )
{
	GetApp()->SetErr( nErrCode );
}


void CLoginGate::OnSend( int nTransferred )
{
#ifdef _DEBUG
//	if(nTransferred > 10)
//	GetApp()->SetLog( CSEND, "[LoginGate/%d] TO (%s)",nTransferred,this->m_dbInfo.szIP );
#endif
}


bool CLoginGate::OnRecv( char *pPacket, int nPacketLen )
{
#ifdef _DEBUG
	char __szPacket[256] = {0,};
	memcpy( __szPacket, pPacket, 
		nPacketLen >= sizeof( __szPacket ) ? sizeof( __szPacket ) - 1 : nPacketLen );
//?	if(nPacketLen >10)
//	GetApp()->SetLog( CRECV, "[LoginGate/%d] %s FROM (%s)", nPacketLen, __szPacket,this->m_dbInfo.szIP );
//	GetApp()->SetLog( CRECV, "[LoginGate] m_nCntInvalidPacket (%d)", m_nCntInvalidPacket);
#endif

	//
	// ��Ŷ ��ȿ�� �˻�
	//
	if ( pPacket[0] != '%' || pPacket[nPacketLen - 1] != '$' )
	{
		m_nCntInvalidPacket++;
		return true;
	}
	
	pPacket[nPacketLen - 1] = NULL;

	switch ( pPacket[1] ) 
	{
	case '-':
		OnKeepAlive();
		return true;

	case 'A':
		OnUserData( &pPacket[2] );
		return true;

	case 'O':
		OnUserOpen( &pPacket[2] );
		return true;
	
	case 'X':
		OnUserClose( &pPacket[2] );
		return true;
	}

	m_nCntInvalidPacket++;
#ifdef _EX_DEBUG
	GetApp()->SetLog( CDBG, "����! LOGIN ����Ʈ �߸��� ��Ŷ ���ŵ�!! %s %d\n", __FILE__, __LINE__ );
#endif
	return false;
}


bool CLoginGate::OnExtractPacket( char *pPacket, int *pPacketLen )
{
	char *pEnd = (char *) memchr( m_olRecv.szBuf, '$', m_olRecv.nBufLen );
	if ( !pEnd )
		return false;

	*pPacketLen = ++pEnd - m_olRecv.szBuf;
	memcpy( pPacket, m_olRecv.szBuf, *pPacketLen );

	return true;
}



int CLoginGate::GetCertification()
{
	static long s_nCert = 30;

	InterlockedIncrement( &s_nCert );

	if ( s_nCert >= 0x7FFFFFFF ) 
		InterlockedExchange( &s_nCert, 30 );
	
	return s_nCert;
}



char * CLoginGate::__cbGetUserKey( sGateUser *pUser )
{
	return pUser->szUserHandle;
}

// Update Log...2003/01/08 COPark
// ClientVersion Check�� ���� OnProtocol �Լ� �߰�
bool CLoginGate::OnProtocol( sGateUser *pUser, char *pBody, _TDEFAULTMESSAGE msg )
{
	if ( strlen( pUser->szID ) == 0 )
	{
		SendKickUser( pUser );
		delete m_listUser.Remove( pUser );	//sonmg 2005/01/31
		return false;
	}

	if(msg.nRecog < VERSION_NUMBER) 
	{
		SendResponse(pUser, SM_VERSION_FAIL, 0, 0, 0, 0);
		return false;
	}
	else 
	{
		SendResponse(pUser, SM_VERSION_AVAILABLE, 0, 0, 0, 0);
		pUser->nClientVersion = msg.nRecog;	
		pUser->bVersionAccept = true;
		return true;
	}
}	
