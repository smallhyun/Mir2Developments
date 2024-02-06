

/*
	A* Path Finding Algorithm

	Date:
		2002/02/25

	Note:
		Ŭ���� T�� �Ʒ��� �Լ����� �����Ͽ��� �Ѵ�.
		
		class T
		{
		public:
			int  GetGoalEstimate( T *pGoal );
			bool GetSuccessors( CAStar< T > *pFinder, T *pParent );
			int  GetCost( T *pState );

			bool IsSameState( T *pState );
			bool IsGoal( T *pState );
		};
*/
#ifndef __ORZ_ALGORITHM_ASTAR_PATH_FINDING__
#define __ORZ_ALGORITHM_ASTAR_PATH_FINDING__


#include "pqueue.h"
#include "list.h"


#define ASTAR_DEF_CAPACITY	100
#define ASTAR_DEF_INCREASE	100


template< class T > 
class CAStar
{
protected:
	class CNode
	{
	public:	
		CNode *pParent;
		CNode *pChild;

		T   state;		// ��� ������
		int	f, g, h;	// �� ����� ���(Cost) (f = g + h)

	public:
		CNode() 
		: pParent( NULL ), pChild( NULL ), f( 0 ), g( 0 ), h( 0 ) 
		{
		}
	};

public:
	int	  m_nState;
	int   m_nSteps;

	CNode *m_pStart;
	CNode *m_pGoal;
	CNode *m_pCurSolutionNode;

	CPriorityQueue< CNode >	m_openQueue;
	CList< CNode >			m_closedList;
	CList< CNode >			m_successors;

public:
	enum
	{
		SEARCH_STATE_NOT_INITIALIZED,
		SEARCH_STATE_SEARCHING,
		SEARCH_STATE_SUCCEEDED,
		SEARCH_STATE_FAILED,
		SEARCH_STATE_OUT_OF_MEMORY,
		SEARCH_STATE_INVALID
	};

	CAStar( int nCapacity = ASTAR_DEF_CAPACITY, int nIncrease = ASTAR_DEF_INCREASE );
	virtual ~CAStar();
	
	void ClearAll();
	void ClearUnusedNodes();
	void Reset();

	bool SetState( T *pStart, T *pGoal );
	int  SearchStep();
	bool AddSuccessor( T *pState );

	T *  GetPathFirst();
	T *  GetPathNext();
	int  GetStepCount();

protected:
	static int __cbCmpCost( void *pArg, CNode *pFirst, CNode *pSecond );
};


template< class T >
CAStar< T >::CAStar( int nCapacity, int nIncrease )
: m_openQueue( nCapacity, nIncrease )
{
	m_nState			= SEARCH_STATE_NOT_INITIALIZED;
	m_nSteps			= 0;
	m_pStart			= NULL;
	m_pGoal				= NULL;
	m_pCurSolutionNode	= NULL;

	m_openQueue.SetCompareFunction( __cbCmpCost, NULL );
}


template< class T >
CAStar< T >::~CAStar()
{
	ClearAll();
}


template< class T >
void CAStar< T >::ClearAll()
{
	if ( m_nState == SEARCH_STATE_SUCCEEDED )
	{
		if ( m_pStart->pChild )
		{
			CNode *pTemp;
			
			do
			{
				pTemp	 = m_pStart;
				m_pStart = m_pStart->pChild;
				delete pTemp;
				
			} while ( m_pStart != m_pGoal );
			
			delete m_pStart;
		}
		else
		{
			// �������� ��ǥ�����̹Ƿ� ����/�� ��常 �����ش�.
			delete m_pStart;
			delete m_pGoal;
		}
	}
	else
	{
		m_openQueue.ClearAll();
		m_closedList.ClearAll();

		if ( m_pGoal )
			delete m_pGoal;
	}

	m_pStart = NULL;
	m_pGoal  = NULL;
	
	m_successors.ClearAll( false );
}


template< class T >
void CAStar< T >::ClearUnusedNodes()
{
	// OPEN ����� ������ ���� ��� ����
	int openIndex;
	for ( openIndex = 0; openIndex < m_openQueue.GetCount(); openIndex++ )
	{
		if ( !m_openQueue[openIndex]->pChild )
			delete m_openQueue.DequeueIndex( openIndex-- );
	}

	m_openQueue.ClearAll( false );

	// CLOSED ����� ������ ���� ��� ����
	CListNode< CNode > *pNode, *pTemp;
	for ( pNode = m_closedList.GetHead(); pNode; )
	{
		if ( !pNode->GetData()->pChild )
		{
			pTemp = pNode->GetNext();
			delete m_closedList.RemoveNode( pNode );
			pNode = pTemp;
			continue;
		}

		pNode = pNode->GetNext();
	}

	m_closedList.ClearAll( false );
}


template< class T >
void CAStar< T >::Reset()
{
	ClearAll();

	m_openQueue.ResetVector();
}


template< class T >
bool CAStar< T >::SetState( T *pStart, T *pGoal )
{
	if ( m_pStart || m_pGoal )
		Reset();

	m_pStart = new CNode;
	if ( !m_pStart )
		return false;

	m_pGoal  = new CNode;
	if ( !m_pGoal )
	{
		delete m_pStart;
		m_pStart = NULL;
		return false;
	}

	m_pStart->state = *pStart;
	m_pGoal ->state = *pGoal;

	m_nState = SEARCH_STATE_SEARCHING;
	m_nSteps = 0;

	// �������� OPEN ��Ͽ� �߰�
	m_pStart->g = 0;
	m_pStart->h = pStart->GetGoalEstimate( pGoal );
	m_pStart->f = m_pStart->g + m_pStart->h;
	
	m_openQueue.Enqueue( m_pStart );

	return true;
}


template< class T >
int CAStar< T >::SearchStep()
{
	if ( m_nState == SEARCH_STATE_NOT_INITIALIZED	||
		 m_nState == SEARCH_STATE_SUCCEEDED			|| 
		 m_nState == SEARCH_STATE_FAILED )
	{
		return m_nState;
	}

	// OPEN ��尡 �ϳ��� ���ٴ� ���� ���̻� ã�� ��ΰ� ���ٴ� ���̴�.
	if ( !m_openQueue.GetCount() )
	{
		return m_nState = SEARCH_STATE_FAILED;
	}

	++m_nSteps;

	// ���� ������ ��带 ������. (f ���� ���� ���� ���)
	CNode *pNode = m_openQueue.Dequeue();

	// ���� ��尡 ��ǥ�����̶��
	if ( pNode->state.IsGoal( &m_pGoal->state ) )
	{
		m_pGoal->pParent = pNode->pParent;

		// ��θ� �������ؼ� �ϼ��Ѵ�.
		if ( pNode != m_pStart )
		{
			delete pNode;

			CNode *pNodeChild  = m_pGoal;
			CNode *pNodeParent = m_pGoal->pParent;

			do
			{
				pNodeParent->pChild = pNodeChild;

				pNodeChild  = pNodeParent;
				pNodeParent = pNodeParent->pParent;

			} while ( pNodeChild != m_pStart );
		}

		// ������ ���� ���(OPEN/CLOSED ����Ʈ) ����
		ClearUnusedNodes();

		return m_nState = SEARCH_STATE_SUCCEEDED;
	}

	// ���� ���(Successor) ��� ����
	m_successors.ClearAll( false );

	// ���� ����� Successor���� ���´�. (Ÿ�� ����̶�� ������ Ÿ�ϵ��̴�.)
	if ( !pNode->state.GetSuccessors( this, pNode->pParent ? &pNode->pParent->state : NULL ) )
	{
		delete pNode;
		m_successors.ClearAll( true );
		ClearAll();
		return m_nState = SEARCH_STATE_OUT_OF_MEMORY;
	}

	int g;			// cost G
	int openIndex;	// pqueue index
	CListNode< CNode > *pSuccessorNode, *pClosedNode, *pTemp;
	CNode *pSuccessor;
	
	// ���� ��� ���(Successor)���� �����Ѵ�.
	for ( pSuccessorNode = m_successors.GetHead(); pSuccessorNode; )
	{
		pSuccessor = pSuccessorNode->GetData();

		g = pNode->g + pNode->state.GetCost( &pSuccessor->state );

		// �̹� ���� ��尡 �����ϸ� �� ���� ����� �ƴ϶�� �����Ѵ�.
		for ( openIndex = 0; openIndex < m_openQueue.GetCount(); openIndex++ )
		{
			if ( m_openQueue[openIndex]->state.IsSameState( &pSuccessor->state ) )
				break;
		}

		if ( openIndex < m_openQueue.GetCount() )
		{
			if ( m_openQueue[openIndex]->g <= g )
			{
				pTemp = pSuccessorNode->GetNext();
				delete m_successors.RemoveNode( pSuccessorNode );
				pSuccessorNode = pTemp;
				continue;
			}

			// �� ���� ������ ���� �����͸� �����Ѵ�.	
			delete m_openQueue.DequeueIndex( openIndex );
		}

		// CLOSED ����Ʈ ���� ���� ��尡 �����ϴ��� �˻��Ͽ� ó���Ѵ�.
		for ( pClosedNode = m_closedList.GetHead(); pClosedNode; pClosedNode = pClosedNode->GetNext() )
		{
			if ( pClosedNode->GetData()->state.IsSameState( &pSuccessor->state ) )
				break;
		}

		if ( pClosedNode )
		{
			if ( pClosedNode->GetData()->g <= g )
			{
				pTemp = pSuccessorNode->GetNext();
				delete m_successors.RemoveNode( pSuccessorNode );
				pSuccessorNode = pTemp;
				continue;
			}

			delete m_closedList.RemoveNode( pClosedNode );
		}

		// ������� ������ ���� ���(Successor)�� ���ݱ����� ���� ������ ����̴�.
		pSuccessor->pParent	= pNode;
		pSuccessor->g		= g;
		pSuccessor->h		= pSuccessor->state.GetGoalEstimate( &m_pGoal->state );
		pSuccessor->f		= pSuccessor->g + pSuccessor->h;

		m_openQueue.Enqueue( pSuccessor );

		// ���� ���(Successor)�� �˻��Ѵ�.
		pSuccessorNode = pSuccessorNode->GetNext();
	}

	// ó���� ���� CLOSED ��Ͽ� ����ִ´�.
	m_closedList.Insert( pNode );

	return m_nState;
}


// class T�� GetSuccessors �Լ����� �� �Լ��� ȣ���ؾ� �Ѵ�.
template< class T >
bool CAStar< T >::AddSuccessor( T *pState )
{
	CNode *pNode = new CNode;
	if ( !pNode )
		return false;

	pNode->state = *pState;
	m_successors.Insert( pNode );

	return true;
}


template< class T >
T * CAStar< T >::GetPathFirst()
{
	if ( !m_pStart )
		return NULL;

	m_pCurSolutionNode = m_pStart;

	return &m_pCurSolutionNode->state;
}


template< class T >
T * CAStar< T >::GetPathNext()
{
	if ( !m_pCurSolutionNode || !m_pCurSolutionNode->pChild )
		return NULL;

	T *pState = &m_pCurSolutionNode->pChild->state;

	m_pCurSolutionNode = m_pCurSolutionNode->pChild;

	return pState;
}


template< class T >
int CAStar< T >::GetStepCount()
{
	return m_nSteps;
}


template< class T >
int CAStar< T >::__cbCmpCost( void *pArg, CNode *pFirst, CNode *pSecond )
{
	return pSecond->f - pFirst->f;
}


#endif