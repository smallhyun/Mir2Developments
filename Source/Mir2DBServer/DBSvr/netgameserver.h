

#ifndef __ORZ_MIR2_GAME_SERVER__
#define __ORZ_MIR2_GAME_SERVER__


#include <netiocp.h>

class CGameServer : public CIocpObject
{
private:
	UINT	m_nLoadCount;
	UINT	m_nSaveCount;
	UINT	m_nLoadFailCount;
	UINT	m_nSaveFailCount;

public:
	enum { CLASSID = IOCP_OBJECT_CLASSID_0 + 2 };

	int  m_nCntInvalidPacket;
	
public:
	CGameServer( SOCKET sdClient );
	virtual ~CGameServer();

	//---------------------------------------------------------------------------------------------
	// DB Server -> Game SErver
	//---------------------------------------------------------------------------------------------
	bool SendResponse		( int nCert, char *pData );
	bool SendResponse		( int nCert, int result , char *UserName , int RetCmdNum , int CmdNum ,char *pData  );
	
	
	//---------------------------------------------------------------------------------------------
	// GameServer -> DB Server
	//---------------------------------------------------------------------------------------------
	bool OnLoadHumanRcd		( int nCert, char *pBody );	// �ɸ��� ������ ����
	bool OnSaveHumanRcd		( int nCert, char *pBody ); // �ɸ��� ������ ����
	bool OnSaveAndChange	( int nCert, char *pBody ); // 

	// For Friend System...
	bool OnFriendList		( int nCert, char *pBody ); // �ڽ��� ����� ���� ����Ʈ ��û
	bool OnFriendOwnList	( int nCert, char *pBody ); // �ڽ��� ����� ���� ����Ʈ ��û 
	bool OnFriendAdd		( int nCert, char *pBody ); // ���� �߰� 
	bool OnFriendDelete		( int nCert, char *pBody ); // ���� ���� 
	bool OnFriendEdit		( int nCert, char *pBody ); // ģ�� �������� ���� 
	
	// For Tag System...
	bool OnTagAdd			( int nCert, char *pBody ); // ���� �߰�
	bool OnTagDelete		( int nCert, char *pBody ); // ���� ���� 
	bool OnTagDeleteAll		( int nCert, char *pBody ); // ���� ���� ���� 
	bool OnTagList			( int nCert, char *pBody ); // ���� ����Ʈ ��û 
	bool OnTagSetInfo		( int nCert, char *pBody ); // ���� ���¼��� 
	bool OnTagRejectAdd		( int nCert, char *pBody ); // �ź��� �߰�
	bool OnTagRejectDelete	( int nCert, char *pBody ); // �ź��� ���� 
	bool OnTagRejectList	( int nCert, char *pBody ); // �ź��� ����Ʈ ��û
	bool OnTagNotReadCount	( int nCert, char *pBody ); // �������� ���� ���� ��û 

	// For RelationShip...
	bool OnLMList			( int nCert, char *pBody ); // ���� ����Ʈ ��û 
	bool OnLMAdd			( int nCert, char *pBody ); // ���� �߰� 
	bool OnLMEdit			( int nCert, char *pBody ); // ���� �������� ���� 
	bool OnLMDelete			( int nCert, char *pBody ); // ���� ���� 
	bool OnFameAdd			( int nCert, char *pBody ); // ���� ����
	//---------------------------------------------------------------------------------------------
	// CIocpObject �����Լ� ����
	//---------------------------------------------------------------------------------------------
	void OnError( int nErrCode );
	void OnSend( int nTransferred );
	bool OnRecv( char *pPacket, int nPacketLen );
	bool OnExtractPacket( char *pPacket, int *pPacketLen );

	//---------------------------------------------------------------------------------------------
	// ���� ����
	//---------------------------------------------------------------------------------------------
	bool IsValidData( int nCert, char *pData, int nDataLen );

	bool SaveUserItem(CConnection *pConn, MIRDB_TABLE* pTable, LPTUserItem pUserItem, int nType, char *pszName , int nPos);
	bool SaveBagItem(CConnection *pConn, LPTBagItem pBagItem, char *pszName);
	bool SaveSaveItem(CConnection *pConn, LPTSaveItem pSaveItem, char *pszName);
	bool SaveUseMagic(CConnection *pConn, LPTUseMagic pUseMagic, char *pszName );
	bool SaveQuest(CConnection *pConn, LPTHuman lptHuman, char *pszName);

	bool LoadQuest(CConnection *pConn, LPTHuman lptHuman, char *pszName);

	//
	void ShowStatusLog();
};


#endif