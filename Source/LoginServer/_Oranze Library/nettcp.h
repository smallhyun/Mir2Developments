

/*
	TCP Handler for Game

	Date:
		2001/10/23

	Note:
		�������ݿ� ���� CopyCompletionPacket() �Լ��� �������̵��Ѵ�.
*/
#ifndef __ORZ_NETWORK_TCP_HANDLER__
#define __ORZ_NETWORK_TCP_HANDLER__


#include "netbase.h"
#include "queue.h"
#include "streambf.h"
#include "syncobj.h"


#define TCP_MAXBUF						4096
#define TCP_THREAD_LOOP_TERM			40

// ��Ʈ�� �����ð� �⺻ ���� ��
#define TCP_DEF_TIMEOUT					30000

// Ŭ����(CTcpHandler)�� ���°�
#define TCP_UNINIT						0
#define TCP_INIT						1
#define TCP_WAITING_THREAD				11

// Poll �Լ��� ��ȯ ��
#define TCP_CONNECT_TRYING				1	// ���� �õ���
#define TCP_CONNECT						2	// ���� ����
#define TCP_RECV						3	// ���ŵ� �����Ͱ� ����
#define TCP_DISCONNECT					11	// ���� ����
#define TCP_ERR_CONNECT					21	// ������ �� ����
#define TCP_ERR_SEND					22	// �۽��� �� ����
#define TCP_ERR_RECV					23	// ������ �� ����


class CTcpPacket
{
public:
	char	*m_pBuf;
	ulong	m_nBufLen;
	
public:
	CTcpPacket( int nBufLen );
	virtual ~CTcpPacket();

	operator char * ()				{ return m_pBuf; }
	operator const char * const ()	{ return (const char *) m_pBuf; }

	char *	Data()					{ return m_pBuf; }
	ulong	Size()					{ return m_nBufLen; }
};


class CTcpHandler : public CNetBase, CIntLock
{
public:
	byte	m_nInstanceState;	// �ν��Ͻ��� ���� ��
	HANDLE	m_hNetIoThread;		// TCP IO ������ �ڵ�

	uint	m_nMaxTimeOut;

	ushort	m_nState;			// ��Ʈ�� ���� �� (Poll �Լ��� ��ȯ ��)
	SOCKET	m_sdHost;

	CQueue< CTcpPacket >	m_qSend;	
	CTcpPacket				*m_pOutputPacket;	// ���� ��� ��Ŷ
	ulong					m_nOutputBytes;		// ���� ��� ��Ŷ�� ���� ����
	CStreamBuffer< char >	m_qRecv;			// ���������� Queue�� ����.	

public:
	CTcpHandler();
	virtual ~CTcpHandler();

	void Reset();

	bool Connect( CSockAddr *pAddr, uint nMaxTimeOut = TCP_DEF_TIMEOUT );
	bool Connect( char *pAddr, short nPort, uint nMaxTimeOut = TCP_DEF_TIMEOUT );
	void Disconnect();

	bool Poll( ushort *pState, CTcpPacket **ppPacket );
	void Send( char *pBuf, uint nBufLen );

protected:
	virtual bool CopyCompletionPacket( char *pBuf, int nBufLen, CTcpPacket **ppPacket );

	void ProcessInput();
	void ProcessOutput();
	void ProcessExcept();

	static uint __stdcall NetIoThread( void *pContext );
};


#endif