// AgsClipboard.cpp : Provides Windows clipboard integration as an AGS plugin
// Copyright (c) 2018 Gunnar Harboe
//
// Based on ags_template.cpp : Example AGS plugin file
// Copyright (c) 2002 Chris Jones
// 
// And on MSDN example clipboard code:
// https://msdn.microsoft.com/en-us/library/ms649016%28VS.85%29.aspx
//
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include "stdafx.h"

#define THIS_IS_THE_PLUGIN
#include "agsplugin.h"

// DllMain - standard Windows DLL entry point.
// The AGS editor will cause this to get called when the editor first
// starts up, and when it shuts down at the end.
BOOL APIENTRY DllMain(HANDLE hModule,
	DWORD  ul_reason_for_call,
	LPVOID lpReserved) {

	switch (ul_reason_for_call) {
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}

// ***** DESIGN TIME CALLS *******

IAGSEditor *editor;
const char *ourScriptHeader =
"#define CLIPBOARD_PLUGIN\r\n"
"#define CLIPBOARD_PLUGIN_VERSION 0.04\r\n"
"/// Methods to access the Windows clipboard (via AGS Clipboard Plugin)\r\n"
"builtin struct Clipboard {\r\n"
"  /// Paste a String from the clipboard. Returns null if not available\r\n"
"  import static String PasteText ();\r\n"
"  /// Copy a String to the clipboard. Returns true if successful\r\n"
"  import static bool CopyText (String copyString);\r\n"
"};\r\n";

LPCSTR AGS_GetPluginName(void) {
	// Return the plugin description
	return "AGS Clipboard Plugin v0.4";
}

int  AGS_EditorStartup(IAGSEditor *lpEditor) {
	// User has checked the plugin to use it in their game

	// If it's an earlier version than what we need, abort.
	if (lpEditor->version < 1)
		return -1;

	editor = lpEditor;
	editor->RegisterScriptHeader(ourScriptHeader);

	// Return 0 to indicate success
	return 0;
}

void AGS_EditorShutdown() {
	// User has un-checked the plugin from their game
	editor->UnregisterScriptHeader(ourScriptHeader);
}

void AGS_EditorProperties(HWND parent) {
	// User has chosen to view the Properties of the plugin
	// We could load up an options dialog or something here instead
	MessageBox(parent, "AGS Clipboard Plugin v0.4\r\nCopy and paste text to and from the Windows clipboard using Clipboard.CopyString() and Clipboard.PasteString().\r\n\r\nCopyright (c) 2018 Gunnar Harboe\r\nhttps://github.com/messengerbag/Clipboard", "About", MB_OK | MB_ICONINFORMATION);
}

int AGS_EditorSaveGame(char *buffer, int bufsize) {
	// We don't want to save any persistent data
	return 0;
}

void AGS_EditorLoadGame(char *buffer, int bufsize) {
	// Nothing to load for this dummy plugin
}

// ******* END DESIGN TIME  *******


// ****** RUN TIME ********

IAGSEngine *engine;

const char* Clipboard_PasteText(void) {
	HGLOBAL   hglb;
	LPTSTR    lptstr;
	const char* pasteString = nullptr;

	if (!IsClipboardFormatAvailable(CF_TEXT))
		return nullptr;
	if (!OpenClipboard(engine->GetWindowHandle()))
		return nullptr;

	hglb = GetClipboardData(CF_TEXT);
	if (hglb != nullptr)
	{
		lptstr = reinterpret_cast<LPTSTR>(GlobalLock(hglb));
		if (lptstr != nullptr)
		{
			pasteString = engine->CreateScriptString(lptstr);
			GlobalUnlock(hglb);
		}
	}
	CloseClipboard();

	return pasteString;
}

bool Clipboard_CopyText(const char *copyString) {
	LPTSTR  lptstrCopy;
	HGLOBAL hglbCopy;

	if (copyString == nullptr)
		return false;

	// Open the clipboard and empty it. 
	if (!OpenClipboard(engine->GetWindowHandle()))
		return false;
	EmptyClipboard();

	// Allocate a global memory object for the text. 
	hglbCopy = GlobalAlloc(GMEM_MOVEABLE, (strlen(copyString)+1) * sizeof(TCHAR));
	if (hglbCopy == nullptr)
	{
		CloseClipboard();
		return false;
	}

	// Lock the handle and copy the text to the buffer. 
	lptstrCopy = reinterpret_cast<LPTSTR>(GlobalLock(hglbCopy));
	memcpy(lptstrCopy, copyString, strlen(copyString) * sizeof(TCHAR));
	lptstrCopy[strlen(copyString)] = (TCHAR)0;    // null character as string terminator
	GlobalUnlock(hglbCopy);

	// Place the handle on the clipboard. 
	SetClipboardData(CF_TEXT, hglbCopy); 

	// Close the clipboard. 
	CloseClipboard();
	return true;
}

void AGS_EngineStartup(IAGSEngine *lpEngine) {
	engine = lpEngine;

	// Make sure it's got the version with the features we need
	if (engine->version < 3) {
		engine->AbortGame("Engine interface is too old, need newer version of AGS.");
	}

	engine->RegisterScriptFunction("Clipboard::PasteText", Clipboard_PasteText);
	engine->RegisterScriptFunction("Clipboard::CopyText^1", Clipboard_CopyText);
}

void AGS_EngineShutdown() {
	// no work to do here - but if we had created any dynamic sprites,
	// we should delete them here
}

// *** END RUN TIME ****
