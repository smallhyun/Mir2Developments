

#include "netgameserver.h"
#include "loginsvrwnd.h"
#include <stringex.h>
#include <stdlib.h>
#include <stdio.h>
#include <TIME.H>
#include "../common/mir2packet.h"


static struct sGameServerCmdList
{
	int  nPacketID;
	bool (CGameServer:: *pfn)( char *pBody );
} g_cmdList[] = 
{
	ISM_USERCLOSED,	&CGameServer::OnUserClosed,
	ISM_USERCOUNT,& CGameServer::OnUserCount,
	ISM_GAMETIMEOFTIMECARDUSER,& CGameServer::OnGameTimeOfTimeUser,
	ISM_CHECKTIMEACCOUNT,	&CGameServer::OnCheckTimeAccount,
	ISM_REQUEST_PUBLICKEY,	&CGameServer::OnRequestPublicKey,
	ISM_PREMIUMCHECK,	&CGameServer::OnPremiumCheck,
	ISM_EVENTCHECK,		&CGameServer::OnEventCheck,
	ISM_POTCASHLIST,	&CGameServer::OnGetPotCashList,
	ISM_POTCASHADD,	&CGameServer::OnGetPotCashAdd,
	ISM_POTCASHDEL,	&CGameServer::OnGetPotCashDel,
};


static const int g_nCmdCnt = sizeof( g_cmdList ) / sizeof( g_cmdList[0] );


CGameServer::CGameServer( SOCKET sdClient, char *szIP )
{
	SetClassId( CLASSID );
	SetAcceptedSocket( sdClient );


	strcpy(m_dbInfo.szIP, szIP);
	m_dbInfo.nID = 0;
	strcpy(m_dbInfo.szName , "");
	m_nCurUserCnt		= 0;
	m_nMaxUserCnt		= 0;
	m_nCntInvalidPacket	= 0;
	m_nLastTick			= GetTickCount();
}


CGameServer::~CGameServer()
{
}


bool CGameServer::SendCancelAdmissionCert( sCertUser *pUser )
{
	CMir2Packet *pPacket = new CMir2Packet;
	pPacket->Attach( '(' );
	pPacket->Attach( ISM_CANCELADMISSION );
	pPacket->Attach( '/' );
	pPacket->Attach( pUser->szLoginID );
	pPacket->Attach( '/' );
	pPacket->Attach( pUser->nCertification );
	pPacket->Attach( ')' );
#ifdef _DEBUG
	GetApp()->SetLog(0,"[GameServer/Send] ISM_CANCELADMISSION : %s TO (%s)", pUser->szLoginID , this->m_dbInfo.szIP);
#endif	
	Lock();
	bool bRet = Send( pPacket );
	Unlock();

/*	FILE *fp = fopen( "d:\\Admission.txt", "ab" );
	fprintf( fp, "[%s] [%s:%d] %s\r\n", pUser->szLoginID, IP(), Port(), pPacket->m_pPacket );
	fclose( fp );*/

	return bRet;
}

bool CGameServer::SendAccountExpire( sCertUser *pUser )
{
	CMir2Packet *pPacket = new CMir2Packet;
	pPacket->Attach( '(' );
	pPacket->Attach( ISM_ACCOUNTEXPIRED );
	pPacket->Attach( '/' );
	pPacket->Attach(pUser->szLoginID );
	pPacket->Attach( '/' );
	pPacket->Attach( pUser->nCertification );
	pPacket->Attach( ')' );
//#ifdef _DEBUG
	GetApp()->SetLog(0,"[GameServer/Send] ISM_ACCOUNTEXPIRED :%s TO (%s)",pUser->szLoginID, this->m_dbInfo.szIP );
//#endif	
	Lock();
	bool bRet = Send( pPacket );
	Unlock();

	//@@@ (sonmg 2005/02/17)
//	delete GetLoginServer()->m_listCert.Remove( pUser );	//�Ȳ����� ���� �����Ƿ� �̸� �������� �ʴ´�.

	return bRet;
}


bool CGameServer::SendTotalUserCount(int nTotalUserCount)
{
	char szCount[10];
	CMir2Packet *pPacket = new CMir2Packet;
	pPacket->Attach( '(' );
	pPacket->Attach( ISM_TOTALUSERCOUNT );
	pPacket->Attach( '/' );
	pPacket->Attach( itoa(nTotalUserCount, szCount, 10 ));
	pPacket->Attach( ')' );

	Lock();
	bool bRet = Send( pPacket );
	Unlock();

	return bRet;

}

bool CGameServer::SendPublicKey(int nPubKey)
{
	char szCount[10];
	CMir2Packet *pPacket = new CMir2Packet;
	pPacket->Attach( '(' );
	pPacket->Attach( ISM_SEND_PUBLICKEY );
	pPacket->Attach( '/' );
	pPacket->Attach( itoa( nPubKey, szCount, 10 ) );
	pPacket->Attach( ')' );
#ifdef _DEBUG
	GetApp()->SetLog(0,"[GameServer/Send] ISM_SEND_PUBLICKEY : %s", szCount);
#endif	

	Lock();
	bool bRet = Send( pPacket );
	Unlock();

	return bRet;
}

bool CGameServer::SendPremiumResponse(int iGrade, char *pID, char *pUserName, char *szBirthDay)
{
	char cFlag = 0;
	if( iGrade == 2 )
	{
		cFlag = 'Y';
	}
	else if( iGrade == 1 )
	{
		cFlag = 'N';
	}
	else
	{
		return false;
	}

	CMir2Packet *pPacket = new CMir2Packet;
	pPacket->Attach( '(' );
	pPacket->Attach( ISM_PREMIUMCHECK );
	pPacket->Attach( '/' );
	pPacket->Attach( cFlag );
	pPacket->Attach( '/' );
	pPacket->Attach( pID );
	pPacket->Attach( '/' );
	pPacket->Attach( pUserName );
	pPacket->Attach( '/' );
	pPacket->Attach( szBirthDay );
	pPacket->Attach( ')' );
#ifdef _DEBUG
	GetApp()->SetLog(0,"[GameServer/Send] ISM_PREMIUMCHECK : %s (%c)", pID, cFlag);
#endif	

	Lock();
	bool bRet = Send( pPacket );
	Unlock();

	return bRet;
}

bool CGameServer::SendEventCheckResponse(char *pID, char *pUserName)
{
	CMir2Packet *pPacket = new CMir2Packet;
	pPacket->Attach( '(' );
	pPacket->Attach( ISM_EVENTCHECK );
	pPacket->Attach( '/' );
	pPacket->Attach( 'Y' );
	pPacket->Attach( '/' );
	pPacket->Attach( pID );
	pPacket->Attach( '/' );
	pPacket->Attach( pUserName );
	pPacket->Attach( ')' );
#ifdef _DEBUG
	GetApp()->SetLog(0,"[GameServer/Send] ISM_EVENTCHECK : %s", pID);
#endif	

	Lock();
	bool bRet = Send( pPacket );
	Unlock();

	return bRet;
}

bool CGameServer::SendUserPotCash(char *pID, int iCash )
{
	CMir2Packet *pPacket = new CMir2Packet;
	char Deli = 0x0a;

	pPacket->Attach( '(' );
	pPacket->Attach( ISM_POTCASHLIST );
	pPacket->Attach( '/' );
	pPacket->Attach( pID );
	pPacket->Attach( &Deli, 1 );
	pPacket->Attach( iCash );
	//pPacket->Attach( &Deli, 1 );
	pPacket->Attach( ')' );
#ifdef _DEBUG
	GetApp()->SetLog(0,"[GameServer/Send] ISM_POTCASHLIST : %s", pID);
#endif	

	Lock();
	bool bRet = Send( pPacket );
	Unlock();
	return bRet; 
}

bool CGameServer::SendPasswordSuccess( sGateUser *pUser )
{

	SYSTEMTIME st;
    GetLocalTime(&st);	//GetSystemTime
	DWORD nCurrentTime = GetDay(st.wYear, st.wMonth, st.wDay);

/*
	pUser->nAvailableType = 5;

	if ( pUser->dwSeconds + pUser->dwMSeconds  > 0 ) pUser->nAvailableType = 2;
	if ( pUser->dwIpSeconds + pUser->dwIpMSeconds > 0 ) pUser->nAvailableType = 4;
	if (((nCurrentTime > pUser->dwValidFrom )&&(nCurrentTime < pUser->dwValidUntil)) ||((nCurrentTime > pUser->dwMValidFrom ) && (nCurrentTime < pUser->dwMValidUntil)))
		pUser->nAvailableType = 1;	
	if (((nCurrentTime > pUser->dwIpMValidFrom ) && (nCurrentTime < pUser->dwIpMValidUntil))||
		((nCurrentTime > pUser->dwIpValidFrom ) && (nCurrentTime < pUser->dwIpValidUntil)))
		pUser->nAvailableType = 3;
*/

	CMir2Packet *pPacket = new CMir2Packet;
	char Deli = 0x0a;

	pPacket->Attach( '(' );
	pPacket->Attach( ISM_PASSWDSUCCESS );
	pPacket->Attach( '/' );
	pPacket->Attach( pUser->szID );
	pPacket->Attach( &Deli, 1 );
//	pPacket->Attach( '/' );
	pPacket->Attach( pUser->nCertification );
	pPacket->Attach( &Deli, 1 );
//	pPacket->Attach( '/' );
	pPacket->Attach( pUser->nPayMode );
	pPacket->Attach( &Deli, 1 );
//	pPacket->Attach( '/' );
	pPacket->Attach( pUser->nAvailableType );
	pPacket->Attach( &Deli, 1 );
//	pPacket->Attach( '/' );
	pPacket->Attach( pUser->szAddr );
	pPacket->Attach( &Deli, 1 );
//	pPacket->Attach( '/' );
	pPacket->Attach( pUser->nClientVersion );
	pPacket->Attach( ')' );

	Lock();
	bool bRet = Send( pPacket );
	Unlock();

/*	FILE *fp = fopen( "d:\\Admission.txt", "ab" );
	fprintf( fp, "[%s] [%s:%d] %s\r\n", pUser->szID, IP(), Port(), pPacket->m_pPacket );
	fclose( fp );*/

	return bRet;
}


bool CGameServer::OnUserClosed( char *pBody )
{
	bstr szID, szCert;
	_pickstring( pBody, '/', 0, &szID );
	_pickstring( pBody, '/', 1, &szCert );
	char szIPAddr[40];
	

	GetLoginServer()->m_csListCert.Lock();
	sCertUser *pUser = GetLoginServer()->m_listCert.SearchKey( szID );
	if ( !pUser )
	{
		GetLoginServer()->m_csListCert.Unlock();
		return true;
	}

/*	FILE *fp = fopen( "d:\\Admission.txt", "ab" );
	fprintf( fp, "CGameServer::OnUserClosed\r\n" );
	fclose( fp );*/

	strcpy(szIPAddr, pUser->szUserAddr);
	GetLoginServer()->SendCancelAdmissionUser( pUser );
#ifdef _DEBUG
	GetApp()->SetLog( 0, "[GameServer] %s was disconnected", pUser->szLoginID);	
#endif
	delete GetLoginServer()->m_listCert.Remove( pUser );

	GetLoginServer()->m_csListCert.Unlock();

	/* 2003/02/03 �ߺ� ������ üũ
	CConnection *pConnPC = GetLoginServer()->m_dbPoolPC.Alloc();
	CRecordset  *pRec = NULL;
	int  nPCRoomIndex = 0;
	char szQuery[1024];

	if ( !pConnPC )
		return false;

	// ������� IP�� �Ǿ������� Ȯ��
	sprintf( szQuery, "SELECT * FROM TBL_USINGIP WHERE FLD_USINGIP='%s' AND FLD_GAMETYPE='%s'", szIPAddr, GetLoginServer()->m_szGameType );
#ifdef _DEBUG
	GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
#endif
	pRec = pConnPC->CreateRecordset();
	if(pRec && pRec->Execute( szQuery ) && pRec->Fetch())
	{
		nPCRoomIndex = atoi( pRec->Get("FLD_PCBANG") );
	}
	pConnPC->DestroyRecordset( pRec );

	if(nPCRoomIndex)
	{
		// ������� IP����Ʈ ����
		sprintf( szQuery, "DELETE FROM TBL_USINGIP WHERE FLD_USINGIP='%s' AND FLD_GAMETYPE='%s'", szIPAddr, GetLoginServer()->m_szGameType );
	#ifdef _DEBUG
		GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
	#endif
		pRec = pConnPC->CreateRecordset();
		if(pRec)
			pRec->Execute( szQuery );
		pConnPC->DestroyRecordset( pRec );

		// ������� �ߺ� IP����
		sprintf( szQuery, "UPDATE TBL_DUPIP SET FLD_ISOK='1', FLD_KICK = GetDate() FROM TBL_DUPIP WHERE FLD_IP='%s' AND FLD_GAMETYPE='%s' AND FLD_ISOK='0'", szIPAddr, GetLoginServer()->m_szGameType );
	#ifdef _DEBUG
		GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
	#endif
		pRec = pConnPC->CreateRecordset();
		if(pRec)
			pRec->Execute( szQuery );
		pConnPC->DestroyRecordset( pRec );

		// ������� IP���� ����
		sprintf( szQuery, "UPDATE MR3_PCRoomStatusTable SET PCRoomStatus_UsingIPCount = PCRoomStatus_UsingIPCount-1 WHERE PCRoomStatus_PCRoomIndex=%d AND PCRoomStatus_UsingIPCount > 0", nPCRoomIndex);
	#ifdef _DEBUG
		GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
	#endif
		pRec = pConnPC->CreateRecordset();
		if(pRec)
			pRec->Execute( szQuery );
		pConnPC->DestroyRecordset( pRec );
	}
	GetLoginServer()->m_dbPoolPC.Free( pConnPC );
*/
	return true;
}


bool CGameServer::OnUserCount( char *pBody )
{
	//// 203/�̺�Ʈ/0/124

	bstr szHandle, szName, szIndex, szCount;
	//_pickstring(pBody, '/',0,&szHandle);
	_pickstring(pBody, '/',0,&szName);
	_pickstring(pBody, '/',1,&szIndex);
	_pickstring(pBody, '/',2,&szCount);

#ifdef _DEBUG
//	GetApp()->SetLog( 0, "[OnUserCount] %s(%s)=%s", szName, szIndex, szCount );	
#endif

	m_dbInfo.nID = atoi(szIndex);
	strcpy(m_dbInfo.szName , szName);

	m_nCheckTime = GetTickCount();
	m_nCurUserCnt = atoi(szCount);
	
	if(m_nCurUserCnt > m_nMaxUserCnt)
		m_nMaxUserCnt = m_nCurUserCnt;

	int nTotalUserCount = GetLoginServer()->GetTotalUserCount();

	if(nTotalUserCount > GetLoginServer()->m_nMaxTotalUserCount)
		GetLoginServer()->m_nMaxTotalUserCount = nTotalUserCount;
	
	CListNode< CGameServer > *pNode;
	GetLoginServer()->m_listGameServer.Lock();
	pNode = GetLoginServer()->m_listGameServer.GetHead();
	for ( ; pNode; pNode = pNode->GetNext() )
	{
		CGameServer *pObj = pNode->GetData();
		if(pObj)
			pObj->SendTotalUserCount(nTotalUserCount);
	}	
	GetLoginServer()->m_listGameServer.Unlock();

	return true;
}
/*
bool CGameServer::OnGameTimeOfTimeUser( char *pBody )
{
	return true;
}*/

bool CGameServer::OnGameTimeOfTimeUser( char *pBody )
{
	bstr szID, szCert;
	_pickstring( pBody, '/', 0, &szID );
	_pickstring( pBody, '/', 1, &szCert );

	GetLoginServer()->m_csListCert.Lock();
	sCertUser *pUser = GetLoginServer()->m_listCert.SearchKey( szID );
	if ( !pUser )
	{
		GetLoginServer()->m_csListCert.Unlock();
		return true;
	}

	CConnection *pConn = GetLoginServer()->m_dbPool.Alloc();
	if ( !pConn )
	{
		GetLoginServer()->m_csListCert.Unlock();
		return false;
	}

	//------------------------------------
	if( strlen(pUser->szLoginID) > 20 )
		GetApp()->SetLog( CERR, "[LONG-QUERY MESSAGE!!!] %s", pUser->szLoginID );
	//------------------------------------

	DWORD dwSeconds = 0;
	DWORD dwFreeSeconds = 0;
	DWORD dwMSeconds = 0;
	DWORD dwFreeMSeconds = 0;
	char szQuery[1024];
	sprintf( szQuery, "SELECT * FROM TBL_ACCOUNT WHERE FLD_LOGINID='%s'", pUser->szLoginID );
#ifdef _DEBUG
	GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
	GetApp()->SetLog( 0, "[bFreeMode] %d", pUser->bFreeMode);
	GetApp()->SetLog( 0, "[nAvailableType] %d", pUser->nAvailableType);
#endif

	CRecordset *pRec = pConn->CreateRecordset();
	if ( !pRec->Execute( szQuery ) || !pRec->Fetch() )
	{
		pConn->DestroyRecordset( pRec );
	}
	else
	{
		if( !pUser->bFreeMode )
		{
			if( pUser->nAvailableType == 2 || (pUser->nAvailableType >= 6 && pUser->nAvailableType <= 10) )
			{
				dwSeconds		= atoi(pRec->Get("FLD_SECONDS"));
				dwFreeSeconds	= atoi(pRec->Get("FLD_FreeSECONDS"));

				if(strcmp(GetLoginServer()->m_szGameType, "MIR2") ==0)
				{
					dwMSeconds		= atoi(pRec->Get("FLD_M2SECONDS"));
					dwFreeMSeconds	= atoi(pRec->Get("FLD_FreeM2SECONDS"));
				}

				if(strcmp(GetLoginServer()->m_szGameType, "MIR3") ==0)
				{
					dwMSeconds		= atoi(pRec->Get("FLD_M3SECONDS"));
					dwFreeMSeconds	= atoi(pRec->Get("FLD_FreeM3SECONDS"));
				}

#ifdef _DEBUG
				GetApp()->SetLog( 0, "[SQL QUERY] ID %s",  pUser->szLoginID);
				GetApp()->SetLog( 0, "[dwSeconds] %d", dwSeconds);
				GetApp()->SetLog( 0, "[dwFreeSeconds] %d", dwFreeSeconds);
				GetApp()->SetLog( 0, "[dwMSeconds] %d", dwMSeconds);
				GetApp()->SetLog( 0, "[dwFreeMSeconds] %d", dwFreeMSeconds);
#endif

				//��ǰʹ��ʱ��
				DWORD dwUseSeconds = atoi(szCert);
				dwUseSeconds = dwUseSeconds * 60;
				//�޸�ʣ��ʱ�䶨��
				DWORD dwUpdateSeconds = 0;
				DWORD dwUpdateMSeconds = 0;

				if (dwMSeconds == 0)
				{
					dwUpdateSeconds = dwSeconds - dwUseSeconds;
					if (dwUpdateSeconds <= 0)
					{
						sprintf( szQuery, "UPDATE TBL_ACCOUNT SET FLD_SECONDS = %d WHERE FLD_LOGINID='%s'",0, pUser->szLoginID );
					}
					else
					{
						sprintf( szQuery, "UPDATE TBL_ACCOUNT SET FLD_SECONDS = %d WHERE FLD_LOGINID='%s'",dwUpdateSeconds, pUser->szLoginID );
					}
				}
				else
				{
					dwUpdateMSeconds = dwMSeconds - dwUseSeconds;
#ifdef _DEBUG
						GetApp()->SetLog( 0, "[dwUpdateMSeconds] %d", dwUpdateMSeconds);
#endif
					if (dwUpdateMSeconds >= 0)
					{
						sprintf( szQuery, "UPDATE TBL_ACCOUNT SET FLD_M2SECONDS = %d WHERE FLD_LOGINID='%s'",dwUpdateMSeconds, pUser->szLoginID );
					}
					else
					{
						char szQueryEx[1024];

						sprintf( szQueryEx, "UPDATE TBL_ACCOUNT SET FLD_M2SECONDS = %d WHERE FLD_LOGINID='%s'",0, pUser->szLoginID );
#ifdef _DEBUG
						GetApp()->SetLog( 0, "[SQL QueryEx] %s", szQueryEx);
#endif
						CRecordset *pTempRecEx = pConn->CreateRecordset();
						if(pTempRecEx)
							pTempRecEx->Execute( szQueryEx );
						pConn->DestroyRecordset( pTempRecEx );
						
						dwUpdateSeconds = dwSeconds + dwUpdateMSeconds;

						sprintf( szQuery, "UPDATE TBL_ACCOUNT SET FLD_SECONDS = %d WHERE FLD_LOGINID='%s'",dwUpdateSeconds, pUser->szLoginID );

					}

				}
				
#ifdef _DEBUG
				GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
#endif
				CRecordset *pTempRec = pConn->CreateRecordset();
				if(pTempRec)
					pTempRec->Execute( szQuery );
				pConn->DestroyRecordset( pTempRec );
#ifdef _DEBUG
				GetApp()->SetLog( 0, "[GameServer] %s account on game time of time user", pUser->szLoginID);
#endif
			}
		}
		pConn->DestroyRecordset( pRec );
	}

	GetLoginServer()->m_dbPool.Free( pConn );
	
	GetLoginServer()->m_csListCert.Unlock();

	return true;
}


bool CGameServer::OnCheckTimeAccount( char *pBody )
{
	bstr szID, szCert;
	_pickstring( pBody, '/', 0, &szID );
	_pickstring( pBody, '/', 1, &szCert );
	char szIPAddr[40];

	GetLoginServer()->m_csListCert.Lock();
	sCertUser *pUser = GetLoginServer()->m_listCert.SearchKey( szID );
	if ( !pUser )
	{
		GetLoginServer()->m_csListCert.Unlock();
		return true;
	}

	CConnection *pConn = GetLoginServer()->m_dbPool.Alloc();
	if ( !pConn )
	{
		GetLoginServer()->m_csListCert.Unlock();
		return false;
	}

	//------------------------------------
	// Query Warning(sonmg 2005/06/16)
	//�� ���ڿ� üũ(LoginSvr)
	if( strlen(pUser->szLoginID) > 20 )
		GetApp()->SetLog( CERR, "[LONG-QUERY MESSAGE!!!] %s", pUser->szLoginID );
	//------------------------------------

	// DB���� �����ð� �˻�...
	DWORD dwSeconds = 0;
	DWORD dwFreeSeconds = 0;
	DWORD dwMSeconds = 0;
	DWORD dwFreeMSeconds = 0;
	char szQuery[1024];
	sprintf( szQuery, "SELECT * FROM TBL_ACCOUNT WHERE FLD_LOGINID='%s'", pUser->szLoginID );
#ifdef _DEBUG
	GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
#endif

	CRecordset *pRec = pConn->CreateRecordset();
	if ( !pRec->Execute( szQuery ) || !pRec->Fetch() )
	{
		pConn->DestroyRecordset( pRec );
	}
	else
	{
		if( !pUser->bFreeMode )
		{
			if( pUser->nAvailableType == 2 || (pUser->nAvailableType >= 6 && pUser->nAvailableType <= 10) )
			{
				dwSeconds		= atoi(pRec->Get("FLD_SECONDS"));
				dwFreeSeconds	= atoi(pRec->Get("FLD_FreeSECONDS"));

				if(strcmp(GetLoginServer()->m_szGameType, "MIR2") ==0)
				{
					dwMSeconds		= atoi(pRec->Get("FLD_M2SECONDS"));

					//Free
					dwFreeMSeconds	= atoi(pRec->Get("FLD_FreeM2SECONDS"));
				}

				if(strcmp(GetLoginServer()->m_szGameType, "MIR3") ==0)
				{
					dwMSeconds		= atoi(pRec->Get("FLD_M3SECONDS"));

					//Free
					dwFreeMSeconds	= atoi(pRec->Get("FLD_FreeM3SECONDS"));
				}

				// ���� �ð� ���� : ���� �ð��� ������...
				if( dwSeconds + dwFreeSeconds + dwMSeconds + dwFreeMSeconds == 0 )
				{
					strcpy(szIPAddr, pUser->szUserAddr);
//					GetLoginServer()->SendCancelAdmissionUser( pUser );
					GetLoginServer()->SendAccountExpireUser( pUser );
#ifdef _DEBUG
					GetApp()->SetLog( 0, "[GameServer] %s account is expired", pUser->szLoginID);
#endif
//					delete GetLoginServer()->m_listCert.Remove( pUser );	//�Ȳ����� ���� �����Ƿ� �̸� �������� �ʴ´�.
				}
			}
		}

		//@@@ (sonmg 2005/02/17)
		pConn->DestroyRecordset( pRec );
	}

	GetLoginServer()->m_dbPool.Free( pConn );

	GetLoginServer()->m_csListCert.Unlock();

	return true;
}

bool CGameServer::OnRequestPublicKey( char *pBody )
{
	SendPublicKey( GetSavedKey() );

	return true;
}

bool CGameServer::OnPremiumCheck( char *pBody )
{
	bstr szID, szCert, szSvName, szUName;
	_pickstring( pBody, '/', 0, &szID );
	_pickstring( pBody, '/', 1, &szCert );
	_pickstring( pBody, '/', 2, &szSvName );
	_pickstring( pBody, '/', 3, &szUName );
	char szLoginID[40];
	char szServerName[40];
	char szUserName[40];
	strncpy( szLoginID, szID, 30 );
	strncpy( szServerName, szSvName, 30 );
	strncpy( szUserName, szUName, 30 );

	GetLoginServer()->m_csListCert.Lock();
	sCertUser *pUser = GetLoginServer()->m_listCert.SearchKey( szID );
	if ( !pUser )
	{
//		GetLoginServer()->m_csListCert.Unlock();
//		return true;
	}

	CConnection *pConn = GetLoginServer()->m_dbPool.Alloc();
	if ( !pConn )
	{
		GetLoginServer()->m_csListCert.Unlock();
		return false;
	}

	//------------------------------------
	// Query Warning(sonmg 2005/06/16)
	//�� ���ڿ� üũ(LoginSvr)
//	if( strlen(pUser->szLoginID) > 20 )
//		GetApp()->SetLog( CERR, "[LONG-QUERY MESSAGE!!!] %s", pUser->szLoginID );
	//------------------------------------

	SYSTEMTIME st;
	GetLocalTime(&st);	//GetSystemTime
	unsigned int nCurrentTime = GetDay(st.wYear, st.wMonth, st.wDay);

	char cBasicFlag[10];
	char cSpecialFlag[10];
	DWORD dwEndDate = 0;
	DWORD dwForceDate = 0;

	char szQuery[1024];
	sprintf( szQuery, "SELECT * FROM TBL_M2PREMIUMUSER WHERE FLD_LOGINID='%s' AND FLD_SERVERNAME='%s' AND FLD_CHARNAME='%s'", szLoginID, szServerName, szUserName );
#ifdef _DEBUG
	GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
#endif

	int iGrade = 0;
	bool bResult = false;
	CRecordset *pRec = pConn->CreateRecordset();
	if ( !pRec->Execute( szQuery ) || !pRec->Fetch() )
	{
		pConn->DestroyRecordset( pRec );
	}
	else
	{
		memset(cSpecialFlag, 0, sizeof(cSpecialFlag));
		strcpy(cSpecialFlag , pRec->Get("FLD_SPECIALFLAG"));
		memset(cBasicFlag, 0, sizeof(cBasicFlag));
		strcpy(cBasicFlag , pRec->Get("FLD_BASICFLAG"));

		//�÷��� �˻�
		if (cSpecialFlag[0] == 'Y' || cSpecialFlag[0] == 'y')
		{
			iGrade = 2;
			bResult = true;
		}
		else
		{
			if (cBasicFlag[0] == 'Y' || cBasicFlag[0] == 'y')
			{
				iGrade = 1;
				bResult = true;
			}
		}

		//��ȿ ��¥ �˻�
		dwEndDate = GetTimeInfo(pRec->Get("FLD_ENDDATE"));

		//������ DWORD�������� ����
		char szBirthDay[20];
		strcpy(szBirthDay, GetDateString(pRec->Get("FLD_BIRTHDAY")));

		//ForceDate(���� ��� ���� ��¥)
		dwForceDate = GetTimeInfo(pRec->Get("FLD_FORCEDATE"));

		//---------------------------------
		//���� �ð�/��¥�� ��
		if( nCurrentTime <= dwEndDate )
		{
			bResult = true;
		}
		else
		{
			bResult = false;
		}
		//---------------------------------

		//---------------------------------
		//���� �ð�/��¥�� ��
		if( nCurrentTime <= dwForceDate )
		{
			//������ ���� ��¥�� ����
			memset(szBirthDay, 0, sizeof(szBirthDay));
			sprintf(szBirthDay, "%d-%d-%d", st.wYear, st.wMonth, st.wDay);

			bResult = true;
		}
		//---------------------------------

		if( bResult )
		{
			//���Ӽ����� ��� ������
			SendPremiumResponse( iGrade, szID, szUserName, szBirthDay );
		}

		//@@@ (sonmg 2005/02/17)
		pConn->DestroyRecordset( pRec );
	}

	GetLoginServer()->m_dbPool.Free( pConn );

	GetLoginServer()->m_csListCert.Unlock();

	return true;
}

bool CGameServer::OnEventCheck( char *pBody )
{
	bstr szID, szCert, szSvName, szUName;
	_pickstring( pBody, '/', 0, &szID );
	_pickstring( pBody, '/', 1, &szCert );
	_pickstring( pBody, '/', 2, &szSvName );
	_pickstring( pBody, '/', 3, &szUName );
	char szLoginID[40];
	char szServerName[40];
	char szUserName[40];
	strncpy( szLoginID, szID, 30 );
	strncpy( szServerName, szSvName, 30 );
	strncpy( szUserName, szUName, 30 );

	GetLoginServer()->m_csListCert.Lock();
	sCertUser *pUser = GetLoginServer()->m_listCert.SearchKey( szID );
	if ( !pUser )
	{
//		GetLoginServer()->m_csListCert.Unlock();
//		return true;
	}

	CConnection *pConn = GetLoginServer()->m_dbPool.Alloc();
	if ( !pConn )
	{
		GetLoginServer()->m_csListCert.Unlock();
		return false;
	}

	//------------------------------------
	// Query Warning(sonmg 2005/06/16)
	//�� ���ڿ� üũ(LoginSvr)
//	if( strlen(pUser->szLoginID) > 20 )
//		GetApp()->SetLog( CERR, "[LONG-QUERY MESSAGE!!!] %s", pUser->szLoginID );
	//------------------------------------

	SYSTEMTIME st;
	GetLocalTime(&st);	//GetSystemTime
	unsigned int nCurrentTime = GetDay(st.wYear, st.wMonth, st.wDay);

	char cForceFlag[10];
	DWORD dwFirstLoginDate = 0;

	char szQuery[1024];
	sprintf( szQuery, "SELECT * FROM EVENT_COMEBACK2005 WHERE FLD_LOGINID='%s'", szLoginID );
#ifdef _DEBUG
	GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
#endif

	bool bResult = false;
	CRecordset *pRec = pConn->CreateRecordset();
	if ( !pRec->Execute( szQuery ) || !pRec->Fetch() )
	{
		pConn->DestroyRecordset( pRec );
	}
	else
	{
		memset(cForceFlag, 0, sizeof(cForceFlag));
		strcpy(cForceFlag , pRec->Get("FLD_FORCEFLAG"));

		//ó�� ���� ��¥ �˻�
		dwFirstLoginDate = GetTimeInfo(pRec->Get("FLD_FIRSTLOGIN"));

		//��¥�� ������ ó�� �����ϴ� ����.
		if( dwFirstLoginDate == 0 )
		{
			//ó�� �������� �� ���� ��¥/�ð��� �����.
			dwFirstLoginDate = nCurrentTime;
			sprintf( szQuery, "UPDATE EVENT_COMEBACK2005 SET FLD_FIRSTLOGIN=GETDATE() WHERE FLD_LOGINID='%s'", szLoginID );
			
			//������Ʈ ���� ����
			CRecordset *pTempRec = pConn->CreateRecordset();
			if(pTempRec)
				pTempRec->Execute( szQuery );
			pConn->DestroyRecordset( pTempRec );
		}

		//���� �ð��� ó�� �������� ������ 30�� ���� ���� �ִ��� Ȯ��
		if( (nCurrentTime >= dwFirstLoginDate) && (nCurrentTime <= dwFirstLoginDate + 30) )
		{
			bResult = true;
		}

		//���� �÷��� �˻� : Y �̸� ������ Enable ����, N �̸� ������ Disable ����.
		if (cForceFlag[0] == 'Y' || cForceFlag[0] == 'y')
		{
			bResult = true;
		}
		else if (cForceFlag[0] == 'N' || cForceFlag[0] == 'n')
		{
			bResult = false;
		}

		//����� ����
		if( bResult )
		{
			//���Ӽ����� ��� ������
			SendEventCheckResponse( szID, szUserName );
		}

		//@@@ (sonmg 2005/02/17)
		pConn->DestroyRecordset( pRec );
	}

	GetLoginServer()->m_dbPool.Free( pConn );

	GetLoginServer()->m_csListCert.Unlock();

	return true;
}


//PCʹ���¼�BEGIN
bool CGameServer::OnGetPotCashList( char *pBody )
{
	bstr szID, szCert;
	_pickstring( pBody, '/', 0, &szID );
	_pickstring( pBody, '/', 1, &szCert );

	GetLoginServer()->m_csListCert.Lock();
	sCertUser *pUser = GetLoginServer()->m_listCert.SearchKey( szID );
	if ( !pUser )
	{
		GetLoginServer()->m_csListCert.Unlock();
		return true;
	}

	CConnection *pConn = GetLoginServer()->m_dbPool.Alloc();
	if ( !pConn )
	{
		GetLoginServer()->m_csListCert.Unlock();
		return false;
	}

	if( strlen(pUser->szLoginID) > 20 )
		GetApp()->SetLog( CERR, "[LONG-QUERY MESSAGE!!!] %s", pUser->szLoginID );

	DWORD dwPotCash = 0;
	char szQuery[1024];
	sprintf( szQuery, "SELECT * FROM TBL_ACCOUNT WHERE FLD_LOGINID='%s'", pUser->szLoginID );
#ifdef _DEBUG
	GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
#endif

	CRecordset *pRec = pConn->CreateRecordset();
	if ( !pRec->Execute( szQuery ) || !pRec->Fetch() )
	{
		pConn->DestroyRecordset( pRec );
	}
	else
	{
		dwPotCash		= atoi(pRec->Get("FLD_POTCASH"));
		SendUserPotCash( szID, dwPotCash );
#ifdef _DEBUG
		GetApp()->SetLog( 0, "[GameServer] %s Account Get PotCash", pUser->szLoginID);
#endif
	}

	GetLoginServer()->m_dbPool.Free( pConn );

	GetLoginServer()->m_csListCert.Unlock();
	return true;
}

bool CGameServer::OnGetPotCashAdd( char *pBody )
{
	bstr szID, szCert;
	_pickstring( pBody, '/', 0, &szID );
	_pickstring( pBody, '/', 1, &szCert );

	GetLoginServer()->m_csListCert.Lock();
	sCertUser *pUser = GetLoginServer()->m_listCert.SearchKey( szID );
	if ( !pUser )
	{
		GetLoginServer()->m_csListCert.Unlock();
		return true;
	}

	CConnection *pConn = GetLoginServer()->m_dbPool.Alloc();
	if ( !pConn )
	{
		GetLoginServer()->m_csListCert.Unlock();
		return false;
	}

	if( strlen(pUser->szLoginID) > 20 )
		GetApp()->SetLog( CERR, "[LONG-QUERY MESSAGE!!!] %s", pUser->szLoginID );

	DWORD dwPotCash = 0;
	DWORD dwPotCashAdd = 0;
	char szQuery[1024];
	sprintf( szQuery, "SELECT * FROM TBL_ACCOUNT WHERE FLD_LOGINID='%s'", pUser->szLoginID );
#ifdef _DEBUG
	GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
#endif

	CRecordset *pRec = pConn->CreateRecordset();
	if ( !pRec->Execute( szQuery ) || !pRec->Fetch() )
	{
		pConn->DestroyRecordset( pRec );
	}
	else
	{
		dwPotCash		= atoi(pRec->Get("FLD_POTCASH"));
		dwPotCashAdd    = atoi(szCert);

		DWORD dwUpdateSeconds = 0;

		dwUpdateSeconds = dwPotCash + dwPotCashAdd;

		sprintf( szQuery, "UPDATE TBL_ACCOUNT SET FLD_POTCASH = %d WHERE FLD_LOGINID='%s'",dwUpdateSeconds, pUser->szLoginID );



#ifdef _DEBUG
		GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
#endif
		CRecordset *pTempRec = pConn->CreateRecordset();
		if(pTempRec)
			pTempRec->Execute( szQuery );
		pConn->DestroyRecordset( pTempRec );

#ifdef _DEBUG
		GetApp()->SetLog( 0, "[GameServer] %s Account PotCash Increase %d", pUser->szLoginID, dwPotCashAdd);
#endif
		SendUserPotCash( szID, dwUpdateSeconds );
	}

	GetLoginServer()->m_dbPool.Free( pConn );

	GetLoginServer()->m_csListCert.Unlock();
	return true;
}

bool CGameServer::OnGetPotCashDel( char *pBody )
{
	bstr szID, szCert;
	_pickstring( pBody, '/', 0, &szID );
	_pickstring( pBody, '/', 1, &szCert );

	GetLoginServer()->m_csListCert.Lock();
	sCertUser *pUser = GetLoginServer()->m_listCert.SearchKey( szID );
	if ( !pUser )
	{
		GetLoginServer()->m_csListCert.Unlock();
		return true;
	}

	CConnection *pConn = GetLoginServer()->m_dbPool.Alloc();
	if ( !pConn )
	{
		GetLoginServer()->m_csListCert.Unlock();
		return false;
	}

	if( strlen(pUser->szLoginID) > 20 )
		GetApp()->SetLog( CERR, "[LONG-QUERY MESSAGE!!!] %s", pUser->szLoginID );

	DWORD dwPotCash = 0;
	DWORD dwPotCashdDel = 0;
	char szQuery[1024];
	sprintf( szQuery, "SELECT * FROM TBL_ACCOUNT WHERE FLD_LOGINID='%s'", pUser->szLoginID );
#ifdef _DEBUG
	GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
#endif

	CRecordset *pRec = pConn->CreateRecordset();
	if ( !pRec->Execute( szQuery ) || !pRec->Fetch() )
	{
		pConn->DestroyRecordset( pRec );
	}
	else
	{
		dwPotCash		= atoi(pRec->Get("FLD_POTCASH"));
		dwPotCashdDel    = atoi(szCert);

		DWORD dwUpdateSeconds = 0;

		dwUpdateSeconds = dwPotCash - dwPotCashdDel;

		sprintf( szQuery, "UPDATE TBL_ACCOUNT SET FLD_POTCASH = %d WHERE FLD_LOGINID='%s'",dwUpdateSeconds, pUser->szLoginID );



#ifdef _DEBUG
		GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
#endif
		CRecordset *pTempRec = pConn->CreateRecordset();
		if(pTempRec)
			pTempRec->Execute( szQuery );
		pConn->DestroyRecordset( pTempRec );

#ifdef _DEBUG
		GetApp()->SetLog( 0, "[GameServer] %s Account PotCash Delete %d", pUser->szLoginID, dwPotCashdDel);
#endif
		SendUserPotCash( szID, dwUpdateSeconds );
	}

	GetLoginServer()->m_dbPool.Free( pConn );

	GetLoginServer()->m_csListCert.Unlock();
	return true;
}
//PCʹ���¼�END

bool CGameServer::SaveServerUserCount()
{
	char szQuery[256];
	
	CConnection *pConn = GetLoginServer()->m_dbPool.Alloc();
	if ( !pConn )
		return false;
	
	sprintf(szQuery, "INSERT INTO TBL_USERCOUNT (FLD_NAME, FLD_INDEX, FLD_TIME,"
					" FLD_COUNT, FLD_MAXCOUNT,FLD_GAMETYPE) VALUES( '%s', %d, GetDate(),%d,%d,'%s')" 
					, m_dbInfo.szName, m_dbInfo.nID, m_nCurUserCnt, m_nMaxUserCnt,GetLoginServer()->m_szGameType  );

#ifdef _DEBUG
	GetApp()->SetLog( 0, "[SQL QUERY] %s", szQuery);
#endif

	CRecordset *pRec = pConn->CreateRecordset();
	pRec->Execute(szQuery);
	pConn->DestroyRecordset(pRec );
	m_nMaxUserCnt = 0;
	GetLoginServer()->m_dbPool.Free( pConn );
	return true;
}



void CGameServer::OnError( int nErrCode )
{
	GetApp()->SetErr( nErrCode );
}


void CGameServer::OnSend( int nTransferred )
{
#ifdef _DEBUG
//	if(nTransferred > 10)
//	GetApp()->SetLog( CSEND, "[GameServer/Send %d]  TO (%s)", nTransferred,this->m_dbInfo.szIP   );
#endif
}


bool CGameServer::OnRecv( char *pPacket, int nPacketLen )
{
#ifdef _DEBUG
	char __szPacket[256] = {0,};
	memcpy( __szPacket, pPacket, 
		nPacketLen >= sizeof( __szPacket ) ? sizeof( __szPacket ) - 1 : nPacketLen );
//	if(nPacketLen> 15)
//	GetApp()->SetLog( CRECV, "[GameServer/Recv %d] %s FROM (%s)", nPacketLen , __szPacket ,this->m_dbInfo.szIP);
#endif

	m_nLastTick = GetTickCount();
	
	//
	// ��Ŷ ��ȿ�� �˻�
	//
	if ( pPacket[0] != '(' || pPacket[nPacketLen - 1] != ')' )
	{
		m_nCntInvalidPacket++;
		return true;
	}

	pPacket[nPacketLen - 1] = NULL;

	//
	// ù��° ��Ʈ���� ��Ŷ ID�̴�.
	//
	bstr szPacketID;
	_pickstring( &pPacket[1], '/', 0, &szPacketID );

	char *pBody = pPacket + strlen( szPacketID ) + 2;

	//
	// �ش� �������� �Լ��� ȣ���Ѵ�.
	//
	for ( int i = 0; i < g_nCmdCnt; i++ )
	{
		if ( atoi( szPacketID ) == g_cmdList[i].nPacketID )
		{
			(this->*g_cmdList[i].pfn)( pBody );
			return true;
		}
	}
	GetApp()->SetLog( 0, "[Invalid Packet] %s", pPacket);
	m_nCntInvalidPacket++;
	return false;
}


bool CGameServer::OnExtractPacket( char *pPacket, int *pPacketLen )
{
	char *pEnd = (char *) memchr( m_olRecv.szBuf, ')', m_olRecv.nBufLen );
	if ( !pEnd )
		return false;

	*pPacketLen = ++pEnd - m_olRecv.szBuf;
	memcpy( pPacket, m_olRecv.szBuf, *pPacketLen );
	
	return true;
}

