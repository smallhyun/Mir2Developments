

#ifndef __ORZ_MIR2_LOGINSVR_WINDOW__
#define __ORZ_MIR2_LOGINSVR_WINDOW__

#include <time.h>
#include "mir2wnd.h"
#include "dlgcfg.h"
#include "netloginsvr.h"


//
// ����Ʈ ��Ʈ�� �ؽ�Ʈ �÷�
//
#define CINFO		RGB(  0,  0,255)
#define CERR		RGB(255,  0,  0)
#define CNORMAL		RGB(  0,  0,  0)
#define CDBG		RGB(255,128, 64)
#define CSEND		RGB( 64, 64,128)
#define CRECV		RGB( 32,128, 64)


class CLoginSvrWnd : public CMir2Wnd
{
public:
	SCFG		m_conf;
	CLoginSvr	m_loginSvr;

public:
	CLoginSvrWnd();
	virtual ~CLoginSvrWnd();

	bool OnInit();
	void OnUninit();
	void OnStartService();
	void OnReload();
	void OnStopService();
	void OnConfiguration();
	void OnInitDB();
	void OnNotInService();
	long OnTimer( int nTimerID );
};


CLoginSvrWnd		* GetApp();
SCFG				* GetCfg();
CLoginSvr			* GetLoginServer();
CDBSvrOdbcPool		* GetOdbcPool();
CDBSvrOdbcPool		* GetOdbcPoolPC();
int					GetTimeInfo(char* buf);
char*				GetDateString(char* buf);
int					GetDay (int iYear, int iMonth, int iDay);
bool				isOlderthen15(char *szSsn);		//�ùٸ� �ֹε�Ϲ�ȣ���� üũ�ϴ� �Լ�
bool				isCorrectSsn(char * szSsn);		//�ùٸ� �ֹε�Ϲ�ȣ�ΰ�� ��15���̻����� üũ
bool				CompareBirthDay (int nCurrent, DWORD dwBirthDay);

#endif
