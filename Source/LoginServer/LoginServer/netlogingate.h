

#ifndef __ORZ_MIR2_LOGIN_GATE__
#define __ORZ_MIR2_LOGIN_GATE__


#include <netiocp.h>
#include "dbtable.h"
#include <indexmap.h>
#include "../common/endecode.h"


#define MAX_GATEUSER_HASHSIZE	1000


struct sGateUser
{
	int		nGateSocket;		// User's LoginGate Socket
	char	szUserHandle[25];	// User's Socket in LoginGate (HashKey!)

	char	szID[25];
	char	szAddr[20];
	char	szSsno[20];
	BYTE	nPayMode;			// ���ݸ��  0:ü����, 1:����, 2:�����̿���
	int		nClientVersion;
	int		nCertification;

	DWORD	nPassFailTime;
	int		nPassFailCount;
	bool	bVersionAccept;
	bool	bSelServerOK;		// ��ŷ ����

	//���� ���� ����ڰ���
	DWORD	dwValidFrom;
	DWORD	dwValidUntil;
	DWORD	dwMValidFrom;
	DWORD	dwMValidUntil;
	
	//���� ���� ����ڰ���
	DWORD	dwSeconds;
	DWORD	dwMSeconds;

	///////////////////////////////////////
	//���� ���� ����ڰ���(2004/06/07)
	DWORD	dwFreeValidFrom;
	DWORD	dwFreeValidUntil;
	DWORD	dwFreeMValidFrom;
	DWORD	dwFreeMValidUntil;
	
	///////////////////////////////////////
	//���� ���� ����ڰ���(2004/06/07)
	DWORD	dwFreeSeconds;
	DWORD	dwFreeMSeconds;

	//���ӹ� ���װ���
	DWORD	dwIpValidFrom;
	DWORD	dwIpValidUntil;
	DWORD	dwIpMValidFrom;
	DWORD	dwIpMValidUntil;

	//���ӹ� ��������
	long	dwIpSeconds;
	long	dwIpMSeconds;
//	DWORD	dwIpSeconds;
//	DWORD	dwIpMSeconds;

	//�������
	DWORD	dwStopUntil;
	DWORD	dwMStopUntil;

	DWORD	dwMakeTime;
	DWORD	dwOpenTime;

	BYTE	nAvailableType;
	bool	bFreeMode;

	int		nServerID;
	int		nParentCheck;
};


class CLoginGate : public CIocpObject
{
public:
	enum { CLASSID = IOCP_OBJECT_CLASSID_0 + 3 };

	sTblPubIP	m_dbInfo;
	int			m_nCntInvalidPacket;

	CIndexMap< sGateUser >	m_listUser;

public:
	CLoginGate( SOCKET sdClient, sTblPubIP *pGateInfo );
	virtual ~CLoginGate();

	//
	// DB Server -> RunGate
	//
	bool SendKickUser( sGateUser *pUser );
	bool SendResponse( sGateUser *pUser, 
					   int nPacketID, 
					   int nRecog = 0, int nParam = 0, int nTag = 0, int nSeries = 0, char *pData = NULL );
	
	//
	// Data ��Ŷ('A') Handler
	//
	bool OnIdPassword( sGateUser *pUser, char *pBody, _TDEFAULTMESSAGE msg );
	bool OnSelectServer( sGateUser *pUser, char *pBody, _TDEFAULTMESSAGE msg );
	bool OnProtocol( sGateUser *pUser, char *pBody, _TDEFAULTMESSAGE msg );

	//
	// LoginGate -> LoginServer
	//
	bool OnKeepAlive();
	bool OnUserData( char *pBody );
	bool OnUserOpen( char *pBody );
	bool OnUserClose( char *pBody );

	//
	// CIocpObject �����Լ� ����
	//
	void OnError( int nErrCode );
	void OnSend( int nTransferred );
	bool OnRecv( char *pPacket, int nPacketLen );
	bool OnExtractPacket( char *pPacket, int *pPacketLen );

	//
	// ��� ����
	//
	int  GetCertification();


protected:
	static char * __cbGetUserKey( sGateUser *pUser );
};


#endif
