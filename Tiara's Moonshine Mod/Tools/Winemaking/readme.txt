myExe2Aut - The Open Source AutoIT Script Decompiler 2.0
========================================================


*New* full support for AutoIT v3.2.6++ :)


... mmh here's what I merely missed in the 'public sources 3.1.0'
This program is for studying the 'Compiled' AutoIt3 format.
 
AutoHotKey was developed from AutoIT and so scripts are nearly the same.

Drag the compiled *.exe or *.a3x into the AutoIT Script Decompiler textbox.
To copy text or to enlarge the log window double click on it. 



Supported Obfuscators:
'Jos van der Zande AutoIt3 Source Obfuscator v1.0.14 [June 16, 2007]' ,
'Jos van der Zande AutoIt3 Source Obfuscator v1.0.15 [July  1, 2007]' ,
'Jos van der Zande AutoIt3 Source Obfuscator v1.0.20 [Sept  8, 2007]' ,
'Jos van der Zande AutoIt3 Source Obfuscator v1.0.22 [Oct  18, 2007]' and
'EncodeIt 2.0'


Tested with:
	AutoIT	 : v3.2.9.4 and 
	AutoHotKey: v1.0.47.4



The options:
===========

'Force Old Script Type'
	Grey means auto detect and is the best in most cases. However if auto detection fails
	or is fooled through modification try to enable/disable this setting
	
'Don't delete temp files (compressed script)'	
	this will keep *.pak files you may try to unpack manually with'LZSS.exe' as well as *.tok DeTokeniser files, tidy backups and *.tbl (<-Used in van Zande obfucation).	
	Default:OFF
	
'Verbose LogOutput'
	When checked you get verbose information when decompiling(DeTokenise) new 3.2.6+ compiled Exe
	Default:OFF
	
'Restore Includes'
	will separated/restore includes.
	requires ';<AUT2EXE INCLUDE-START' comment to be present in the script to work
	Default:ON
	
'Use 'normal' Au3_Signature to find start of script'
	Will uses the normal 16-byte start signature to detect the start of a script
	often this signature was modified or is used for a fake script that is
	just attached to distract & mislead a decompiler.
	When off it scans for the 'FILE' as encrypted text to find the start of a script
	Default:OFF


'Lookup Passwordhash'
	Copies current password hash to clipboard and launches	
	http://md5cracker.de
	to find the password of this hash. 
	
	I notice that site don't loads properly when the Firefox addin 
	'Firebug' is enabled. Disable it if you've problems
	620AA3997A6973D7F1E8E4B67546E0F6 => cw2k
	
	... you may also get an offline MD5 Cracker and paste the hash there like
	DECRYPT.V2  Brute-Force MD5 Cracker
	http://www.freewarecorner.de/download.php?id=7298
	http://www.freeware.de/Windows/Tools_Utilities/Sicherheit_Backup/Ver__und_Entschluesselung/Detail_EDECRYPT_Brute_Force_MD5_Cracker_9832.html
	http://www.shareware.de/Windows/Tools_Utilities/Sicherheit_Backup/Ver__und_Entschluesselung/Detail_EDECRYPT_Brute_Force_MD5_Cracker_9832.html


CommandLine:
===========

	Ah yes to open a file you may also pass it via command line like this
	myAutToExe.exe "C:\Program Files\Example.exe" -> myAutToExe.exe "%1"
	So you may associate exe file with myAutToExe.exe to decompile them with a right click.

	To run myAutToExe from other tools these options maybe helpful
	options:
	/q		will quit myAutToExe when it is finished
	/s		[required /q to be enable] RunSilent will completly hide myAutToExe
	


	


Files
=====

 myAutToExe.exe   Compiled (pCode) VB6-Exe
 RanRot_MT.dll    RanRot & Mersenne Twister pRandom Generator - used to decrypt scriptdata
 LZSS.exe   		Called after to decryption to decompress the script
 Tidy\      		is run after deobfucating to apply indent to the source code
 samples\   		Useful 'protected' example scripts; use myExe2Aut to reveal its the sources
 src_AutToExe_VBA.doc   VBA Version - use this for debugging if you don't have VB6 installed
 src_AutToExe_VB6.vbp	VB6-ProjectFile
 !SourceCode\src\       		VB6 source code
 !SourceCode\Au3-Extracter Script 0.2\	AutoIT Script to decompile a *.au3-exe or *.a3x
 !SourceCode\SRC RanRot_MT.dll - Mersenne Twister & RanRot\ 		C source code for RanRot_MT.dll
 !SourceCode\SRC LZSS.exe\ 			C++ source code for lzss.exe


Known bugs:
On Asian system (Chinese, Japan...) that have DBCS(Double Chars Set) enable
maAutToExe will not run properly (as maybe other VB6 programs).
Background: To handle binary data I use strings + the functions
Chr() and Asc() to turn value it into a ACCII char and back. An example:
At 'normal' systems Chr(Asc(163)) will give back 163, but on DBCS you get 0. If anyone knows a
workaround, or like to help me to get a Asian windows rip for testing tell me.





The Compiled Script AutoIT File format:
--------------------------------------

AutoIt_Signature        size 0x14 Byte  String "£HK...AU3!"
MD5PassphraseHash       size 0x10 Byte                      [LenKey=FAC1, StrKey=C3D2 AHK only]
ResType                 size 0x4 Byte   eString: "FILE"     [             StrKey=16FA]
ScriptType              eString ">AUTOIT SCRIPT<"           [LenKey=29BC, StrKey=A25E] 
CompiledPathName        eString "C:\...\Temp\aut26A.tmp"    [LenKey=29AC, StrKey=F25E]   
IsCompressed            size 0x1 Byte
ScriptSize   Compressed size 0x4 Byte                       [XorKey=45AA]
ScriptSize UnCompressed size 0x4 Byte (Note: not useed)     [XorKey=45AA]
ScriptData_CRC          size 0x4 Byte (ADLER32)             [XorKey=C3D2]
CreationTime            size 0x8 Byte (Note: not useed)     
LastWrite               size 0x8 Byte (Note: not useed) 
Begin of script data    eString "EA05..."
overlaybytes            String
EOF


LenKey => See StringLenKey parameter in decrypt_eString()
StrKey => See StringKey parameter in decrypt_eString()
XorKey => Xor Value with that key


Encrypted String (eString)
================

eString
  Stringlen size 0x4 Byte
  String

decrypt_eString(StringLenKey, StringKey )
    Get32ValueFromFile() => Stringlen 
    XOR Stringlen with StringLenKey

    Read string with 'Stringlen' from File
    
    MT_pseudorandom generator.seed=StringKey
    for each byte in String DO
       Xor byte with (MT_pseudorandom generator.generate31BitValue And &FF)
    next

The pseudorandom generator is call Mersenne Twister thats why MT.
(Version 3.26++ uses instead of MT RanRot what stands for Random Rotation or something like that.).
For that mt.dll ist need. for details see the C source code or Google for 'Mersenne Twister'


Decompressing the Script
========================

FileFormat

Signature   String "EA05"       {"EA06"}
UncompressedSize    0x4 Bytes
CompressedData    x Bytes

Compression is a modified LZSS inspired by an article by Charles Bloom.
Lempel Ziv Storer Szymanski (http://de.wikipedia.org/wiki/Lempel-Ziv-Storer-Szymanski-Algorithmus)

Implementation is inside LZSS.dll -> for exact info see C sources

Beside the speculation where this algo comes from here the pseudocode on how it works

Proc Decompress (InputfileData, DeCompressedData)
   ReadBytes(4)
   Compare with "EA05"       {"EA06"}
   
   UncompressedSize= ReadBytes(4)
   
   while 'decompressed_output' is smaller than 'UncompressedSize' Do
     ReadBits(1)
   
     if bit=1							{or "if bit=0" for version 3.26++}
       // Copy Byte (=8Bit) to output
       writeOutputChar() = ReadBits(8)
   
     else
       BytesToSeekBack = ReadBits(16)
       NumOfBytesToCopy= GetNumOfBytesToCopy()
       
      writeOutputChars() = Read 'NumOfBytesToCopyChar' at (CurrentPosition - BytesToSeekBack) from Output
   
   end while
End Proc


Function NumOfBytesToCopy()

      size = GetBits(2): SizePlus = &H0
      If size = 3 Then

         size = GetBits(3): SizePlus = &H3
         If size = 7 Then

            size = GetBits(5): SizePlus = &HA
            If size = &H1F Then

               size = GetBits(8): SizePlus = &H29
               If size = &HFF Then

                  size = GetBits(8): SizePlus = &H128
                  Do While size = &HFF
                     size = GetBits(8): SizePlus = SizePlus + &HFF
                  Loop

               End If
            End If
         End If
      End If

   Return (size + SizePlus + 3)
End Function

Example A: 

uncompr.String: "<AUT2EX"
will look like this
{0}<{0}A{0}U{0}T{0}2E{0}X{0}E
Note: '{0}' stands for 1 Bit that is 0

Example B: 

uncompr.String: "<EXEabcEXEdef"
Reverse Offset:     87643210

{0}<{0}E{0}X{0}E{0}a{0}b{0}c {1}{0000000000000110}{00} {0}d{0}e{0}f
~Nothing special till here~~ ~~~~~ Look below ~~~~~~~~ ~and again just copy each char to output

{1} 1Bit that is 1 and makes the algo to go into the else branche
{0000000000000110} 15 Bits that give represents the Bytes to seek back here it says 6 bytes
{00}    2 bytes the specify the length here it's 0 +3 = 3 Bytes (since 3 is the minimum of repeated chars the algo cares about)


Version differences:
Version 3_0
	Seek to the very end of the script and then back to read
	Script_Start_Offset		size 0x4 Byte
	Script_CRC32_CRC			size 0x4 Byte                       [XorKey=0xAAAAAAAA]
	
	Compare Script_CRC32_CRC with Calulated one from dataScript_Start_Offset to Script_End_Offset-4.
	And seek to Script_Start_Offset reach start of script

Version 3_1
	Seek to the very end of the script and then back to read
	Script_End_Offset			size 0x4 Byte                       [XorKey=0xAAAAAAAA]
	Script_Start_Offset		size 0x4 Byte                       [XorKey=0xAAAAAAAA]
	Script_ADLER32_CRC		size 0x4 Byte                       [XorKey=0xAAAAAAAA]
	
	Compare Script_ADLER32_CRC with Calulated one from dataScript_Start_Offset to Script_End_Offset.
	Seek to Script_Start_Offset and read
	RandomFillData_len		size 0x4 Byte								[XorKey=0xADAC]
	Then seek over RandomFillData_len to reach start of script

Version 3_2
	Seek to the very end of the script and then back to read
	if "AU3!EA05" is found there 
	search entire script for AutoIT Signature to reach start of script
	
Version 3_26
	same as Version 3_2, expect that here it's "AU3!EA06"

History
=======
2.00 Improved commandline handling + ne options /q /s
     options are saved
     BugFix: Van Zande DeObfucator (problem with strings that contained keywords like "LOCALhost")

1.94 Add 'Log Verbose' Checkbox, Bugfixes and speed optimisation in deobfucator
     Delete of tmp & tidybackups-files by default
     
1.93 fixed Bug with AutoHotKey: v1.0.46 scripts

1.92 Support for Obfuscator v1.0.22

1.91 Support for AHK Scripts of the Type "<" and ">"

1.9  Finally full support for AutoIT v3.2.6++ files

1.81 BugFix: password checksum got invalid for new Aut3 files because of 'äöü'(ACCI bigger 7f)-fix

1.8 Added: Support for au3 v3.2.6 + TokenFile
	 BugFix: scripts with passwords like 'äöü'(ACCI bigger 7f) were not corrected decrypted

1.71 Bug fix: output name contained '>' that result in an invalid output filename

1.7 Bug fixes and improvement in 'Includes separator module'
    Added support for old (EA04) AutoIT Scripts
    
1.6 Added: Includes separator module

1.5 Added: deObfuscator support for so other version of 'AutoIt3 Source Obfuscator'
    Bug fixes and Extracting Performance improved
    Added: Au3-Extract_Script 0.2.au3

1.4 Added: deObfuscator Module for older version of 'AutoIt3 Source Obfuscator'

1.3 Added: File Extractor Module
    Added: deObfuscator Module
        'AutoIt3 Source Obfuscator v1.0.15' and EncodeIt 2.0

1.2 added support for AutoHotKey Scripts
    replaced LZSS.dll by LZSS.exe
    added decompression support for EA05-autoit files to LZSS.exe 

1.1 added this readme + MS-Word VBA Version
    Output *.overlay if overlay is more than 8 byte

1.0 initial Version

<cw2k[ät]gmx.de>        http://maghia.free.fr/Board/viewtopic.php?t=234
								http://antiwpa.cwsurf.de/antiwpa/Other/tmp
								http://myAutToExe.angelfire.com/




























========= OutTakes (from previous Versions) =================

Sorry Decryptions for new au3 Files is not implemented yet.
(...and so you can't extract files whose source you don't have.)
(->Scroll to the very end of this file for OllyDebug DIY-dumping infos)

But you can test the TokenDecompiler that is already finished!

Try Sample\AutoIt316_TokenFile\TokenTestFile_Extracted.au3 - or 

DIY:
1. add this line at the beginning of the your au3-sourcecode:

FileInstall('>>>AUTOIT SCRIPT<<<', @ScriptDir & '\ExtractedSource.au3')

2. Compile it with the AutoIt3Compiler.
3. Run the exe -> 'ExtractedSource.au3' get's extracted.
4. Now open 'ExtractedSource.au3' with this decompiler.


Temporary Lastminute appendix....


Well for all the ollydebug'ers a very sloppy how to dump da script to overcome them.

Dumping a Autoit3 3.2.6 Script
==============================

1. ----------------------------
Proc ExtractScript
   push ">>>AUTOIT SCRIPT<<<"
   Call ...
   ...
   XOR     EBX, 0A685
   ...
   Ret
step out of this Function(ret)

2.--------------------------------------------------
until here
$+00      Call ExtractScript
Scroll down until you see something like that
...
$+BE     >|.  E8 8A020000   |CALL    00406F3D
$+C3     >|.  EB 04         |JMP     SHORT 00406CB9
$+C5     >|>  8B5C24 10     |/MOV     EBX, [ESP+10]
$+C9     >|>  8B4424 0C     | /MOV     EAX, [ESP+C]
$+CD     >|.  03C3          |||ADD     EAX, EBX
$+CF     >|.  0FB638        |||MOVZX   EDI, [BYTE EAX]
$+D2     >|.  FF4424 0C     |||INC     [DWORD ESP+C]
$+D6     >|.  8D7424 30     |||LEA     ESI, [ESP+30]
$+DA     >|.  897C24 20     |||MOV     [ESP+20], EDI
$+DE     >|.  E8 23820000   |||CALL    0040EEF6
$+E3     >|.  8B4424 38     |||MOV     EAX, [ESP+38]
$+E7     >|.  83F8 0F       |||CMP     EAX, 0F                       ;  Switch (cases 0..1F)
$+EA     >|.  77 16         |||JA      SHORT 00406CF2
$+EC     >|.  8B4424 0C     |||MOV     EAX, [ESP+C]                  ;  Cases 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F of switch 00406CD7
$+F0     >|.  03D8          |||ADD     EBX, EAX
$+F2     >|.  8B03          |||MOV     EAX, [EBX]

3.--------------------------------------------------
$+CF     >|.  0FB638        |||MOVZX   EDI, [BYTE EAX]
Reads the decrypted/decompressed script 
Set a Breakpoint there and follow EAX

Go back -4 byte and dump anything there.

00D00048  00000015   ... ;Number of Scriptlines
00D0004C  00000B37  7
.. <-EAX Points Here
00D00050  45002800  .(.E
00D00054  5F006400  .d._
00D00058  6A007900  .y.j
00D0005C  42007200  .r.B
00D00060  64006800  .h.d
00D00064  7F006500  .e.
00D00068  00000B31  1
..
00D0006C  42004D00  .M.B
00D00070  4E004700  .G.N
00D00074  45004200  .B.E
4.----------------------------------------------------
Now you can feed that dump file into the decompiler.
