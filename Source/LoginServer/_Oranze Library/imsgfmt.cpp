

#include "imsgfmt.h"
#include "stringex.h"


bool CIMsgFormat::QueryString( char *pBuf, char *pName, char *pValue, int nValueLen )
{
	char szLine[IMSG_MAXLINE], szName[IMSG_MAXLINE];
	bool bFind = false;
	char *pStart, *pEnd = pBuf - strlen( IMSG_NEWLINE );
	char *pToken, *pTokenTmp;

	while ( true )
	{
		// ���� ���ο��� �̸��� ���� �и��Ѵ�.
		pStart = pEnd + strlen( IMSG_NEWLINE );
		pEnd = strstr( pStart, IMSG_NEWLINE );
		if ( !pEnd || (pEnd - pStart) >= IMSG_MAXLINE )
			break;

		memcpy( szLine, pStart, pEnd - pStart );
		szLine[ pEnd - pStart ] = NULL;

		// ù ���ڰ� whitespace��� �̾����� ���̴�.
		if ( bFind )
		{
			if ( szLine[0] == ' ' || szLine[0] == '\t' )
			{
				_trim( szLine );
				nValueLen -= strlen( szLine );
				if ( nValueLen <= 0 )
					break;

				strcat( pValue, szLine );
				continue;
			}
			break;
		}
		
		// �̸��� ��´�.
		pStart = _memistr( szLine, strlen( szLine ), pName );
		if ( !pStart )
			continue;
		
		if ( pStart != szLine && !_isspace( *(pStart - 1) ) && *(pStart - 1) != ';' )
			continue;

		pToken	  = strchr( pStart, ':' );
		pTokenTmp = strchr( pStart, '=' );

		if ( pToken && pTokenTmp )
			pToken = pToken < pTokenTmp ? pToken : pTokenTmp;
		if ( !pToken )
			pToken = pTokenTmp;
	
		if ( !pToken )
			continue;

		memcpy( szName, pStart, pToken - pStart );
		szName[ pToken - pStart ] = NULL;
		_trim( szName );

		// �̸� �� (Case-Insensitive)
		if ( stricmp( szName, pName ) != 0 )
			continue;

		pStart = ++pToken;

		// ���� ��´�.
		bFind = true;

		nValueLen -= strlen( pStart );
		if ( nValueLen <= 0 )
			return false;

		strcpy( pValue, pStart );
		_trim( pValue );
	}

	return bFind ? true : false;
};
