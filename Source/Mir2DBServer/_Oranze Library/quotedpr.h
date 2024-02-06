

/*
	Quoted Printable Type Encoder/Decoder

	Date:
		2001/10/26
*/
#ifndef __ORZ_NETWORK_QUOTED_PRINTABLE__
#define __ORZ_NETWORK_QUOTED_PRINTABLE__


class CQuotedPrintable
{
public:
	/*
		Encode/Decode:
		�Լ� �ȿ��� �˸��� ũ���� �޸�(ppDest)�� �Ҵ��ϹǷ�
		ȣ���ڰ� ��� �� ���� �����ؾ� �Ѵ�.
	*/
	static bool Encode( char *pRaw, int nRawLen, char **ppDest, int *pDestLen );
	static bool Decode( char *pRaw, int nRawLen, char **ppDest, int *pDestLen );

protected:
	static char HexToDec( char *hex, int len );
};


#endif