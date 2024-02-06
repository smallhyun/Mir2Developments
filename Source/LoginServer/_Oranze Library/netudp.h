

/*
	UDP Handler for Game

	Date:
		2001/10/23

	Note:
		PACKET ����
	
		HEADER	: INDEX[4BYTE] + TYPE[2BYTE]
		DATA	: HEADER + DATA
		ACK		: HEADER (HEADER���� INDEX�� ACK INDEX)
*/
#ifndef __ORZ_NETWORK_UDP_HANDLER__
#define __ORZ_NETWORK_UDP_HANDLER__


#include "netbase.h"
#include "list.h"
#include "queue.h"
#include "syncobj.h"


/*
	UDP ��Ŷ �սǷ��� �׽�Ʈ �ϱ� ���ؼ� ������ ������ �� �ִ�.

	#define __UDP_DEBUG__

	Desc:
		SetPacketLoseProbability() �Լ��� Ȱ��ȭ�ȴ�.
*/
#define __UDP_DEBUG__


#define UDP_MAXBUF						4096
#define UDP_THREAD_LOOP_TERM			40

// ȣ��Ʈ WAITING ACK ť �⺻ ũ�� (Sliding Window Size)
#define UDP_DEF_WAITING_ACK_Q_SIZE		10

// ��Ʈ�� �����ð� �⺻ ���� ��
#define UDP_DEF_SYNC_LATENCY			10000
#define UDP_DEF_RTO						1000
#define	UDP_MAX_RETRANSMISSION			10

// Ŭ����(CUdpHandler) �ν��Ͻ��� ���°�
#define UDP_UNINIT						0
#define UDP_INIT						1
#define UDP_WAITING_THREAD				11

// Poll �Լ��� ���� ��ȯ ��
#define UDP_RECV						1	// ���ŵ� �����Ͱ� ����
#define UDP_ERR_SEND					11	// �۽��� �� ���� (ICMP Port Error)
#define UDP_ERR_SEND_RETRANSMISSION		12	// �۽��� �� ���� (Retransmission Error)
#define UDP_ERR_SEND_SYNC				21	// �۽� ����ȭ �ð��� �ʰ��Ǿ���
#define UDP_ERR_RECV_SYNC				22	// ���� ����ȭ �ð��� �ʰ��Ǿ���
#define UDP_ERR_NOT_ENOUGH_BUFFER		91	// �����͸� ������ ���۰� ������

// UDP ��� �ε��� (CUdpPacketHeader::m_nIndex)
#define UDP_PACKET_START				0x00000000
#define UDP_PACKET_END					0xFFFFFFFF

// UDP ��Ŷ ��� Ÿ�� (CUdpPacketHeader::m_nCount)
#define UDP_PACKET_ACK					0
#define UDP_PACKET_DATA					1



class CUdpPacketHeader
{
public:
	ulong	m_nIndex;	// ��Ŷ �ε���
	ulong	m_nCount;	// ������ Ƚ�� (�� ���� 0�̸� ACK ��Ŷ�̴�.)

	CUdpPacketHeader();
	virtual ~CUdpPacketHeader();
};



class CUdpPacket : public CUdpPacketHeader
{
public:
	char	m_buf[UDP_MAXBUF];

	ulong	m_nBufLen;			// ���� ������ ũ��
	ulong	m_nTime;			// ��Ŷ�� ���ʷ� ������ ����
	ulong	m_nTimeWaitingAck;	// ��Ŷ�� ������ ���� (������ ����)

public:
	CUdpPacket();
	virtual ~CUdpPacket();

	operator char * ()				{ return (char *) this; }
	operator const char * () const	{ return (const char *) this; }

	ulong	Size()		{ return sizeof( CUdpPacketHeader ) + UDP_MAXBUF; }
	ulong	UsedSize()	{ return sizeof( CUdpPacketHeader ) + m_nBufLen; }
};



class CUdpHost : public CSockAddr
{
public:
	ushort					m_nState;			// ȣ��Ʈ�� ���� ��

	void					*m_pHostData;		// ȣ��Ʈ�� �ΰ� ������ ���� ����

	CQueue< CUdpPacket >	m_qSend;
	CQueue< CUdpPacket >	m_qWaitingAck;
	CQueue< CUdpPacket >	m_qRecv;

	ulong					m_nLastSendIndex;	// ��Ŷ �Ϸ�ȭ�� ���� �ε���

	ulong					m_nNextPollIndex;	// ��Ŷ �Ϸ�ȭ�� ���� �ε���
	ulong					m_nLastRecvTime;	// ����ȭ ó���� ���� ������ ��Ŷ�� ������ �ð��� �����Ѵ�.

public:
	CUdpHost();
	~CUdpHost();

	bool	InsertToSendQ( ulong nType, uint nIndex, char *pBuf, uint nBufLen );
	bool	InsertToRecvQ( ulong nIndex, char *pBuf, uint nBufLen );
	bool	RemoveFromSendQ( ulong nIndex );
	bool	RemoveFromWaitingAckQ( ulong nIndex );
};



/*
	CUdpHandler Class
*/
class CUdpHandler : public CNetBase, CIntLock
{
public:
	byte				m_nInstanceState;	// Ŭ���� �ν��Ͻ��� ���� ��
	HANDLE				m_hNetIoThread;		// UDP IO ������ �ڵ�

	CSockAddr			m_addr;				
	SOCKET				m_sdHost;
	ulong				m_nMaxSyncLatency;
	ulong				m_nMaxRTO;
	ulong				m_nMaxWaitingAckQSize;

	CList< CUdpHost >	m_listHost;

public:
	CUdpHandler();
	virtual ~CUdpHandler();

	bool Init( CSockAddr *pAddr,
			   uint nMaxSyncLatency = UDP_DEF_SYNC_LATENCY,
			   uint nMaxRTO = UDP_DEF_RTO,
			   uint nMaxWaitingAckQSize = UDP_DEF_WAITING_ACK_Q_SIZE );
	void Uninit();

	bool Poll( CUdpHost **ppHost, ushort *pState, char *pBuf, uint *pBufLen );
	void Send( CUdpHost *pHost, char *pBuf, uint nBufLen );

	CUdpHost * InsertHost( CSockAddr *pAddr, void *pHostData = NULL );
	bool DeleteHost( CSockAddr *pAddr );
	
	CUdpHost * GetHost( CSockAddr *pAddr );
	void SetHostData( CUdpHost *pHost, void *pHostData );

protected:
	void ProcessInput();	// NetIoThread �ȿ��� ȣ��Ǵ� ���� �Լ�
	void ProcessOutput();	

	static uint __stdcall NetIoThread( void *pContext );
	static int  __cbCompareHost( void *pArg, CUdpHost *pFirst, CUdpHost *pSecond );

#ifdef __UDP_DEBUG__
public:
	ulong	m_nPacketLoseProbability;

	void SetPacketLoseProbability( ulong nPacketLoseProbability )
	{
		m_nPacketLoseProbability = nPacketLoseProbability;
	}
#endif
};


#endif


