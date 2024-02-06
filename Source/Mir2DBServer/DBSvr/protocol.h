#pragma once

//=============================================================================
// �������� ��ȣ ���� 
//=============================================================================
// �α��μ������� ���۵Ǵ� �������� LoginServer -> DB
#define ISM_PASSWDSUCCESS		100
#define ISM_CANCELADMISSION		101
#define ISM_USERCLOSED			102
#define ISM_USERCOUNT			103
#define ISM_TOTALUSERCOUNT		104

#define ISM_REQUEST_PUBLICKEY	117
#define ISM_SEND_PUBLICKEY		118

//-----------------------------------------------------------------------------
// ���Ӽ������� ���۵Ǵ� �������� GameServer -> DB
// Main System ----------------------------------------------------------------
#define DB_LOADHUMANRCD			100
#define DB_SAVEHUMANRCD			101
#define DB_SAVEANDCHANGE		102
// Friend System ------------------
#define DB_FRIEND_LIST          125
#define DB_FRIEND_ADD           126
#define DB_FRIEND_DELETE        127
#define DB_FRIEND_OWNLIST       128
#define DB_FRIEND_EDIT          129
// Tag System ---------------------
#define DB_TAG_ADD              130
#define DB_TAG_DELETE           131
#define DB_TAG_DELETEALL        132
#define DB_TAG_LIST             133
#define DB_TAG_SETINFO          134
#define DB_TAG_REJECT_ADD       135
#define DB_TAG_REJECT_DELETE    136
#define DB_TAG_REJECT_LIST      137
#define DB_TAG_NOTREADCOUNT     138
//Relationsip----------------------
#define DB_LM_LIST              139
#define DB_LM_ADD               140
#define DB_LM_EDIT              141
#define DB_LM_DELETE            142
#define DB_FAME_ADD             143

//-----------------------------------------------------------------------------
// ���Ӽ����� ���۵Ǵ� �������� DB->GameServer
// Main System ----------------------------------------------------------------
#define DBR_LOADHUMANRCD		1100
#define DBR_SAVEHUMANRCD		1101
// Friend System -------------------
#define DBR_FRIEND_LIST         1203
#define DBR_FRIEND_WONLIST      1204
#define DBR_FRIEND_RESULT       1205
// Tag System ----------------------
#define DBR_TAG_LIST            1206
#define DBR_TAG_REJECT_LIST     1207
#define DBR_TAG_NOTREADCOUNT    1208
#define DBR_TAG_RESULT          1209
//Relationsip-----------------------
#define DBR_LM_LIST             1210
#define DBR_LM_RESULT           1211


//-----------------------------------------------------------------------------
// ����Ʈ ����Ʈ���� ���۵Ǵ� ��������
//-----------------------------------------------------------------------------
#define CM_QUERYCHR				100
#define CM_NEWCHR				101
#define CM_DELCHR				102
#define CM_SELCHR				103


//-----------------------------------------------------------------------------
// ����Ʈ ����Ʈ�� ���۵Ǵ� �������� 
//-----------------------------------------------------------------------------
#define SM_QUERYCHR				520
#define SM_NEWCHR_SUCCESS		521
#define SM_NEWCHR_FAIL			522
#define SM_DELCHR_SUCCESS		523
#define SM_DELCHR_FAIL			524
#define SM_STARTPLAY			525
#define SM_STARTFAIL			526
#define SM_QUERYCHR_FAIL		527
#define	SM_OUTOFCONNECTION		528


//=============================================================================
// �������� ��Ŷ ����ü
//=============================================================================
#pragma pack( 1 )

// ������ ���õ� ����ü 
struct sAdmission
{
	char szID[21];	// 14 -> 20 , 20 -> 21
	char szIP[15];
	int  nCert;
	int  nPayMode;	// 0: ü��, 1: ����
	bool bSelected;
};

// �ɸ������� ��û�ҋ� ���ȴ� ����ü 
struct sLoadHuman
{
	char szID[21];
	char szName[20]; // 14 -> 20
	char szAddr[15];
	int  nCert;
};


#pragma pack( 8 )