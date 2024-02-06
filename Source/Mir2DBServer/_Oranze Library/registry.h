


/*
	Registry Class

	Date:
		2001/04/12

	Note:
		������ ������Ʈ�� I/O Ŭ����
*/

#ifndef __ORZ_MISC_REGISTRY__
#define __ORZ_MISC_REGISTRY__


#include <windows.h>


#define MAXREGKEY	1024


class CRegistry
{
protected:
	HKEY	m_hKey;

public:
	CRegistry();
	virtual ~CRegistry();

	bool OpenKey( char *pKeyName );
	bool CloseKey();

	bool SetInteger( char *pValueName, int nValueInt );
	bool SetString( char *pValueName, char *pValueString );

	bool GetInteger( char *pValueName, int *pValueInt );
	bool GetString( char *pValueName, char *pValueString, int nValueStringLen );
};


#endif