

#include "quotedpr.h"
#include "datatype.h"


static byte g_szHexaTable[] = "0123456789ABCDEF";


bool CQuotedPrintable::Encode( char *pRaw, int nRawLen, char **ppDest, int *pDestLen )
{
	// quoted HEXA �϶� �ִ� 3�� ũ���� �� �ִ�.
	int nAllocLen = nRawLen * 3; 
	
	*ppDest = new char[ nAllocLen + 1 ];
	if ( !*ppDest )
		return false;

	*pDestLen = 0;

	bool processed;
	int  outputPos = 0;

	for ( int i = 0; i < nRawLen; i++ )
	{
		processed = false;

		// �� ���θ��� soft ��и��� ���δ�.
		if ( outputPos > 72 )
		{
			(*ppDest)[(*pDestLen)++] = '=';
			(*ppDest)[(*pDestLen)++] = '\r';
			(*ppDest)[(*pDestLen)++] = '\n';

			outputPos = 0;
		}

		// ASCII 33 - 60, 62 - 126 ������ ���� tab, space�� �״�� ���δ�.
		if ( (pRaw[i] >= 33 && pRaw[i] <= 60)	|| 
			 (pRaw[i] >= 62 && pRaw[i] <= 126)	|| 
			 pRaw[i] == '\t' || pRaw[i] == ' ' )
		{
			(*ppDest)[(*pDestLen)++] = pRaw[i];
			processed = true;
			outputPos++;
		}

		// �״�� ���� �� ���� ���ڶ�� quoted ó���� �Ѵ�.
		if ( !processed )
		{
			(*ppDest)[(*pDestLen)++] = '=';
			(*ppDest)[(*pDestLen)++] = g_szHexaTable[((byte) pRaw[i]) / 16];
			(*ppDest)[(*pDestLen)++] = g_szHexaTable[((byte) pRaw[i]) % 16];
		}
	}

	(*ppDest)[ *pDestLen ] = '\0';

	return true;
}


bool CQuotedPrintable::Decode( char *pRaw, int nRawLen, char **ppDest, int *pDestLen )
{
	int nAllocLen = nRawLen;

	*ppDest = new char[ nAllocLen + 1 ];
	if ( !*ppDest )
		return false;

	*pDestLen = 0;

	char lastChar		= ' ';
	char secondLastChar	= ' ';
	bool skip;

	for ( int i = 0; i < nRawLen; i++ )
	{
		skip = false;

		// quoted �����̸� ��� �ڵ尡 �ٴ� ���̴�.
		if ( pRaw[i] == '=' )
			skip = true;

		if ( !skip )
		{
			// soft ��и� ó�� (=\r\n)
			if ( lastChar == '=' && 
				(pRaw[i] == ' ' || pRaw[i] == '\t' || pRaw[i] == '\r' ) )
			{
				while ( i < nRawLen && pRaw[++i] != '\n' );

				secondLastChar	= ' ';
				lastChar		= ' ';
				skip			= true;
			}
		}

		if ( !skip )
		{
			if ( lastChar == '=' )
				skip = true;
		}

		if ( !skip )
		{
			// HEXA ó�� (eg. =0D is ASCII 13 decimal)
			if ( secondLastChar == '=' )
			{
				(*ppDest)[(*pDestLen)++] = (char) HexToDec( &pRaw[i - 1], 2 );
				
				secondLastChar	= ' ';
				lastChar		= ' ';
				skip			= true;
			}
		}

		// ���� ���ڴ� ��ȯ���� �ʴ´�.
		if ( !skip )
			(*ppDest)[(*pDestLen)++] = pRaw[i];

		secondLastChar	= lastChar;
		lastChar		= pRaw[i];
	}

	(*ppDest)[ *pDestLen ] = '\0';

	return true;
}


char CQuotedPrintable::HexToDec( char *hex, int len )
{
	int dec  = 0;
	int base = 1;
	int index;

	for ( int i = len - 1; i >= 0; i-- )
	{
		if ( hex[i] >= '0' && hex[i] <= '9' )
			index = hex[i] - '0';
		else
			index = hex[i] - 'A' + 10;

		dec += index * base;
		base *= 16;
	}

	return dec;
}
