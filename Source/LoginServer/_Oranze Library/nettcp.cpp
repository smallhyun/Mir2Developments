

#include "nettcp.h"
#include "process.h"


CTcpPacket::CTcpPacket( int nBufLen )
{
	m_pBuf		= new char[ nBufLen ];
	if ( m_pBuf == NULL )
		throw CError( "CTcpPacket::CTcpPacket �޸� �Ҵ� ����" );
	m_nBufLen	= nBufLen;
}


CTcpPacket::~CTcpPacket()
{
	if ( m_pBuf )
		delete[] m_pBuf;
}




CTcpHandler::CTcpHandler()
{
	m_nInstanceState	= TCP_UNINIT;
	m_hNetIoThread		= NULL;

	m_nMaxTimeOut		= 0;

	m_nState			= 0;
	m_sdHost			= INVALID_SOCKET;

	m_pOutputPacket		= NULL;
	m_nOutputBytes		= 0;
}


CTcpHandler::~CTcpHandler()
{
	Reset();
}


void CTcpHandler::Reset()
{
	Lock();
	
	if ( m_sdHost != INVALID_SOCKET )
	{
		shutdown( m_sdHost, SD_BOTH );
		closesocket( m_sdHost );
		m_sdHost = INVALID_SOCKET;
	}
	
	if ( m_hNetIoThread )
	{
		m_nInstanceState = TCP_WAITING_THREAD;
		
		WaitForSingleObject( m_hNetIoThread, INFINITE );
		CloseHandle( m_hNetIoThread );
		m_hNetIoThread = NULL;
	}

	if ( m_pOutputPacket )
	{
		delete m_pOutputPacket;
		m_pOutputPacket = NULL;
	}
	
	m_nInstanceState = TCP_UNINIT;

	m_qSend.ClearAll();

	Unlock();
}


bool CTcpHandler::Connect( CSockAddr *pAddr, uint nMaxTimeOut )
{
	m_sdHost = socket( AF_INET, SOCK_STREAM, 0 );
	if ( m_sdHost == INVALID_SOCKET )
		throw CError( "CTcpHandler::Init socket ���� ����" );

	ulong nNonblock = 1;
	if ( ioctlsocket( m_sdHost, FIONBIO, &nNonblock ) == SOCKET_ERROR )
		throw CError( "CTcpHandler::Init socket �ͺ� ��� ����" );

	if ( setsockopt( m_sdHost, SOL_SOCKET, SO_SNDTIMEO, (char *) &nMaxTimeOut, sizeof( nMaxTimeOut ) ) == SOCKET_ERROR )
		throw CError( "CTcpHandler::Init setsockopt( SO_SNDTIMEO ) ȣ�� ����" );

	if ( setsockopt( m_sdHost, SOL_SOCKET, SO_RCVTIMEO, (char *) &nMaxTimeOut, sizeof( nMaxTimeOut ) ) == SOCKET_ERROR )
		throw CError( "CTcpHandler::Init setsockopt( SO_RCVTIMEO ) ȣ�� ����" );

	if ( connect( m_sdHost, pAddr, sizeof( SOCKADDR ) ) == SOCKET_ERROR )
	{
		if ( WSAGetLastError() != WSAEWOULDBLOCK )
			throw CError( "CTcpHandler::Init connect ����" );
	}

	m_nMaxTimeOut		= nMaxTimeOut;

	m_nInstanceState	= TCP_INIT;
	m_nState			= TCP_CONNECT_TRYING;

	uint nThreadId;
	m_hNetIoThread = (HANDLE) _beginthreadex( NULL, 0, NetIoThread, this, 0, &nThreadId );
	if ( m_hNetIoThread == NULL )
		throw CError( "CTcpHandler::Init UDP ������ ���� ����" );

	return true;
}


bool CTcpHandler::Connect( char *pAddr, short nPort, uint nMaxTimeOut )
{
	return Connect( CSockAddr( pAddr, nPort ), nMaxTimeOut );
}


void CTcpHandler::Disconnect()
{
	Reset();
}


/*
	Poll()

	�� �Լ��� ���� ���� TCP_RECV���, ����ڰ� �Ҵ�� �޸𸮸� ���� �����ؾ� �Ѵ�.

	��� ��>
	---------------------------------------------------------------
	ushort		nState;
	CTcpPacket	*pPacket;

	while ( Poll( &nState, &pPacket ) )
	{
		if ( nState == TCP_RECV )
		{
			ProcessRecvPacket();
			delete pPacket;  <-----
		}
	}
	---------------------------------------------------------------
*/
bool CTcpHandler::Poll( ushort *pState, CTcpPacket **ppPacket )
{
	Lock();

	if ( m_qRecv.Length() &&
		 CopyCompletionPacket( m_qRecv.Buffer(), m_qRecv.Length(), ppPacket ) )
	{
		m_qRecv.Remove( (*ppPacket)->Size() );

		*pState = TCP_RECV;

		Unlock();
		return true;
	}

	if ( m_nState && m_nState != TCP_RECV )
	{
		*pState = m_nState;

		// �������� �����̹Ƿ� ���� ������ ���� �ѹ��� �˷��ش�. 
		if ( m_nState == TCP_CONNECT )
			m_nState = 0;

		Unlock();
		return true;
	}

	Unlock();
	return false;
}


void CTcpHandler::Send( char *pBuf, uint nBufLen )
{
	CTcpPacket *pPacket = new CTcpPacket( nBufLen );
	if ( pPacket == NULL )
		throw CError( "CTcpHandler::Send �޸� �Ҵ� ����" );

	memcpy( pPacket->m_pBuf, pBuf, nBufLen );

	Lock();
	m_qSend.Enqueue( pPacket );
	Unlock();
}


/*
	CopyCompletionPacket()

	���� ����>
	pBuf		: ���ŵ� ������ ��Ʈ��
	nBufLen		: ������ ��Ʈ���� ũ��
	pPacket		: ������ ��� (�Լ� �ȿ��� �޸𸮸� �Ҵ��ؾ� �Ѵ�.)

	�⺻ ����>
	���ŵ� �����͸� �״�� �����Ѵ�.
*/
bool CTcpHandler::CopyCompletionPacket( char *pBuf, int nBufLen, CTcpPacket **ppPacket )
{
	*ppPacket = new CTcpPacket( nBufLen );
	if ( ppPacket == NULL )
		return false;

	memcpy( (*ppPacket)->m_pBuf, pBuf, nBufLen );

	return true;
}


void CTcpHandler::ProcessInput()
{
	// recv() ����
	char buf[TCP_MAXBUF];
	int	 nRecvLen;

	while ( true )
	{
		nRecvLen = recv( m_sdHost, buf, sizeof( buf ), 0 );
		if ( nRecvLen == 0 )
		{
			m_nState = TCP_DISCONNECT;
			break;
		}
		else if ( nRecvLen < 0 )
		{
			if ( WSAGetLastError() != WSAEWOULDBLOCK )
				m_nState = TCP_ERR_RECV;

			break;
		}

		m_qRecv.Append( buf, nRecvLen );
	}
}


void CTcpHandler::ProcessOutput()
{
	// TCP ������ �̷���� �������� ����� ����������.
	if ( m_nState == TCP_CONNECT_TRYING )
		m_nState = TCP_CONNECT;

	// send() ����
	uint nSendLen;

	if ( m_pOutputPacket == NULL )
		m_pOutputPacket = m_qSend.Dequeue();
	
	while ( m_pOutputPacket )
	{			
		nSendLen = send( m_sdHost, 
						 m_pOutputPacket->Data() + m_nOutputBytes, 
						 m_pOutputPacket->Size() - m_nOutputBytes, 
						 0 );
		
		if ( nSendLen < 0 )
		{
			if ( WSAGetLastError() != WSAEWOULDBLOCK )
				m_nState = TCP_ERR_SEND;

			break;
		}
		
		m_nOutputBytes += nSendLen;
		
		if ( m_pOutputPacket->Size() == m_nOutputBytes )
		{
			delete m_pOutputPacket;
			m_pOutputPacket = m_qSend.Dequeue();
		}
	}
}


/*
	�ͺ� ��忡�� except�� ���� ���и� �ǹ��Ѵ�.
*/
void CTcpHandler::ProcessExcept()
{
	m_nState = TCP_ERR_CONNECT;
}


uint CTcpHandler::NetIoThread( void *pContext )
{
	CTcpHandler *pTcp = (CTcpHandler *) pContext;

	// select() ����
	fd_set		readfds, writefds, exceptfds;
	timeval		timeout;

	while ( pTcp->m_nInstanceState != TCP_WAITING_THREAD )
	{
		Sleep( TCP_THREAD_LOOP_TERM );

		FD_ZERO( &readfds );
		FD_ZERO( &writefds );
		FD_ZERO( &exceptfds );

		FD_SET( pTcp->m_sdHost, &readfds );
		FD_SET( pTcp->m_sdHost, &writefds );
		FD_SET( pTcp->m_sdHost, &exceptfds );

		timeout.tv_sec	= 0;
		timeout.tv_usec	= 0;
		if ( select( 0, &readfds, &writefds, &exceptfds, &timeout ) <= 0 )
			continue;

		pTcp->Lock();

		if ( FD_ISSET( pTcp->m_sdHost, &readfds ) )
			pTcp->ProcessInput();

		if ( FD_ISSET( pTcp->m_sdHost, &writefds ) )
			pTcp->ProcessOutput();

		if ( FD_ISSET( pTcp->m_sdHost, &exceptfds ) )
			pTcp->ProcessExcept();

		pTcp->Unlock();
	}

	return 0;
}
