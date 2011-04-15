/* <<<                                  */
/* Copyright (c) 1994-1996 Arne Riiber. */
/* All rights reserved.                 */
/* >>>                                  */
/* main.c - simulator loop */

/*
 * $Id: main.c,v 1.2 1994/08/23 22:19:54 arne Exp arne $
 *
 * $Log: main.c,v $
 * Revision 1.2  1994/08/23  22:19:54  arne
 * Added reading commands of default .simrc init file.
 * Made reading commands from redirected input possible.
 *
 * Revision 1.1  1994/08/23  07:42:45  arne
 * Initial revision
 *
 *
 */
#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "defs.h"

#ifdef USE_PROTOTYPES
#include "fileio.h"
#endif

#ifdef __MSDOS__
  char *inifile = "sim.rc";
#else
  char *inifile = ".simrc";
#endif

char *progname;

char *
getprogname ()
{
	return progname;
}

main (argc, argv)
	int   argc;
	char *argv[];
{
	int   errcode;
	FILE *ifp;
	char *host;
	int   port;
	char  *filename;
	char *p;

	progname = argv[0];
	filename = argv[1];

	if (argc <= 1)
	{
		fprintf (stderr, "Usage: %s filename", progname);
#ifdef NETCOMMAND
		fprintf (stderr, " [host] [port]");
#endif
		fprintf (stderr, "\n");

		return (1);
	}

	if (argc >= 3)
		host = argv[2];
	else
		host = "localhost";

	if (argc >= 4)
		port = atoi (argv[3]);
	else
		port = 0;

	if (!mem_init ())
		return errno;

	if ((errcode = board_install ()) < 0)
		return errcode;

	if ((errcode = load_file (filename)) != 0)
		return errcode;

	/*
	 * Try opening symbol file
	 */
	sym_readfile (filename, NULL);

	/*
	 * Try opening basename of filename with ".sim" extension
	 */
	{
		char  initfile[1024];
		char *p;
		int   len;

		if (p = strrchr (filename, '.')) {
			/* Skip extension */
			len = (p - filename);
		} else {
			len = strlen (filename);
		}

		strncpy (initfile, filename, len);
		initfile[len] = '\0';
		strcat (initfile, ".sim");
		ifp = fopen (initfile, "rt");
	}

	/*
	 * read commands from init file
	 */
	if (ifp || (ifp = fopen (inifile, "rt"))) {
		commandloop (ifp, host, port);
		close (ifp);
	}

	return commandloop (stdin, host, port);
}


