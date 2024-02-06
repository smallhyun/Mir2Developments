

/*
	UUDecoder

	Date:
		2001/10/26

	Note:
		UUEncoder�� �� �̻� ������ ���� ���̱� ������ ���Խ�Ű�� �ʾҴ�.
*/
#ifndef __ORZ_NETWORK_UUENCODE__
#define __ORZ_NETWORK_UUENCODE__


class CUuDecoder
{
public:
	static bool IsEncoded( char *pRaw );
	static bool Decode( char *pRaw, int nRawLen, char *pName, char **ppDest, int *pDestLen );

protected:
	static void DecodeChunk( char *in, char *out, int count );
};


#endif