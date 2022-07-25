#ifndef M6800_CHIP_H
#define M6800_CHIP_H

/*
 * 6800 memory map
 *
 * Note: 6800 does not have internal registers, but due to the limitations of
 * the simulator architecture, I have added the Altair 680 ACIA as an internal
 * peripheral (otherwise the 6800 wouldn't be able to do anything with no I/O)
 */
#define NIREGS  0x03		/* Number of internal registers */

/*
 * 68B50 ACIA registsers
 */
#define SR	0	/* R Status Register				*/
#define CR	0	/* W Control Register				*/
#define RDR	1	/* R Receive Data Register			*/
#define TDR	1	/* W Transmit Data Register			*/

/*
 * SR (Status Register) bits
 */
#define RDRF	0x01	/* Receive Data Register Full (RDRF)		*/
#define TDRE	0x02	/* Transmit Data Register Empty (TDRE)		*/
#define DCD	0x04	/* Data Carrier Detect (/DCD)			*/
#define CTS	0x08	/* Clear to Send (/CTS)				*/
#define FE	0x10	/* Framing Error (FE)				*/
#define OVRN	0x20	/* Receiver Overrun (OVRN)			*/
#define PE	0x40	/* Parity Error (PE)				*/
#define IRQ	0x80	/* Interrupt Request (/IRQ)			*/

/*
 * CR (Control Register) bits
 */
#define CDS1	0x01	/* Counter Divide Select 1 (CR0)		*/
#define CDS2	0x02	/* Counter Divide Select 2 (CR1)		*/
#define WS1	0x04	/* Word Select 1 (CR2)				*/
#define WS2	0x08	/* Word Select 2 (CR3)				*/
#define WS3	0x10	/* Word Select 3 (CR4)				*/
#define TC1	0x20	/* Transmit Control 1 (CR5)			*/
#define TC2	0x40	/* Transmit Control 2 (CR6)			*/
#define RIE	0x80	/* Receive Interrupt Enable (CR7)		*/

/*
 *	Interrupt vector map
 */
#define IRQVECTOR	0xFFF8	/* IRQ1			*/
#define SWIVECTOR	0xFFFA	/* Software Interrupt	*/
#define NMIVECTOR	0xFFFC	/* NMI			*/
#define RESVECTOR	0xFFFE	/* RESET		*/

#endif
