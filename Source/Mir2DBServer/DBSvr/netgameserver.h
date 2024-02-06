

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
	bool OnLoadHumanRcd		( int nCert, char *pBody );	// 纳腐磐 沥焊甫 佬澜
	bool OnSaveHumanRcd		( int nCert, char *pBody ); // 纳腐磐 沥焊甫 历厘
	bool OnSaveAndChange	( int nCert, char *pBody ); // 

	// For Friend System...
	bool OnFriendList		( int nCert, char *pBody ); // 磊脚捞 殿废茄 蜡历 府胶飘 夸没
	bool OnFriendOwnList	( int nCert, char *pBody ); // 磊脚阑 殿废茄 蜡历 府胶飘 夸没 
	bool OnFriendAdd		( int nCert, char *pBody ); // 蜡历 眠啊 
	bool OnFriendDelete		( int nCert, char *pBody ); // 蜡历 昏力 
	bool OnFriendEdit		( int nCert, char *pBody ); // 模备 技何沥焊 函版 
	
	// For Tag System...
	bool OnTagAdd			( int nCert, char *pBody ); // 率瘤 眠啊
	bool OnTagDelete		( int nCert, char *pBody ); // 率瘤 昏力 
	bool OnTagDeleteAll		( int nCert, char *pBody ); // 率瘤 傈何 昏力 
	bool OnTagList			( int nCert, char *pBody ); // 率瘤 府胶飘 夸没 
	bool OnTagSetInfo		( int nCert, char *pBody ); // 率瘤 惑怕荐沥 
	bool OnTagRejectAdd		( int nCert, char *pBody ); // 芭何磊 眠啊
	bool OnTagRejectDelete	( int nCert, char *pBody ); // 芭何磊 昏力 
	bool OnTagRejectList	( int nCert, char *pBody ); // 芭何磊 府胶飘 夸没
	bool OnTagNotReadCount	( int nCert, char *pBody ); // 佬瘤臼篮 率瘤 俺荐 夸没 

	// For RelationShip...
	bool OnLMList			( int nCert, char *pBody ); // 包拌 府胶飘 夸没 
	bool OnLMAdd			( int nCert, char *pBody ); // 包拌 眠啊 
	bool OnLMEdit			( int nCert, char *pBody ); // 包拌 技何沥焊 函版 
	bool OnLMDelete			( int nCert, char *pBody ); // 包拌 昏力 
	bool OnFameAdd			( int nCert, char *pBody ); // 声望 增加
	//---------------------------------------------------------------------------------------------
	// CIocpObject 啊惑窃荐 备泅
	//---------------------------------------------------------------------------------------------
	void OnError( int nErrCode );
	void OnSend( int nTransferred );
	bool OnRecv( char *pPacket, int nPacketLen );
	bool OnExtractPacket( char *pPacket, int *pPacketLen );

	//---------------------------------------------------------------------------------------------
	// 悼累 备泅
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