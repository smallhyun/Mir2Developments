

/*
	Base64 Encoder/Decoder

	Date:
		2001/10/26
*/
#ifndef __ORZ_NETWORK_BASE64__
#define __ORZ_NETWORK_BASE64__


#include "datatype.h"


class CBase64
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
	static byte FindBase64Val( char c );

	static void EncodeChunk( byte *in, byte *out, byte count );
	static byte DecodeChunk( byte *in, byte *out );
};


#endif