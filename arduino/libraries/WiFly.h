/**
* @author Samuel Mokrani
*
* @section LICENSE
*
* Copyright (c) 2011 mbed
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*
* @section DESCRIPTION
*
* Wifly RN131-C, wifi module
*
* Datasheet:
*
* http://www.sparkfun.com/datasheets/Wireless/WiFi/WiFlyGSX-um2.pdf
*/ 

#ifndef WIFLY_H
#define WIFLY_H

#include "mbed.h"

/** Wifly Class
 *
 * Example:
 * @code
 * #include "mbed.h"
 * #include "Wifly.h"
 *
 * Wifly wifly(p9, p10, p20, "network", "password", true);
 * Serial pc(USBTX, USBRX);
 * 
 * int main()
 * {
 *   
 *   if(wifly.join())
 *       pc.printf("network joined!\r\n");
 *   else
 *       pc.printf("join failed!\r\n");
 *       
 * }
 * @endcode
 */
class Wifly {

    public:
        /**
        * Constructor for joining open, wep or wpa secured networks
        *
        * @param tx mbed pin to use for tx line of Serial interface
        * @param rx mbed pin to use for rx line of Serial interface
        * @param reset reset pin of the wifi module
        * @param ssid ssid of the network
        * @param phrase WEP or WPA key
        * @param wpa true if wpa security false otherwise
        * @param ip ip of the wifi module if dhcp = false (default: NULL)
        * @param netmask netmask if dhcp = false (default: NULL)
        * @param dhcp enable or disable dhcp (default: true)
        * @param baudrate speed of the communication (default: 9600)
        */
        Wifly(  PinName tx, PinName rx, PinName reset, char * ssid, char * phrase, bool wpa, 
                char * ip = NULL, char * netmask = NULL, bool dhcp = true, int baudrate = 9600);
        
        
        
        /**
        * Constructor to create an adhoc network
        *
        * @param tx mbed pin to use for tx line of Serial interface
        * @param rx mbed pin to use for rx line of Serial interface
        * @param ssid ssid of the adhoc network which will be created
        * @param ip ip of the wifi module (default: "169.254.1.1")
        * @param netmask netmask (default: "255.255.0.0")
        * @param channel channel (default: "1")
        * @param baudrate speed of the communication (default: 9600)
        */
        Wifly(  PinName tx, PinName rx, PinName reset, char * ssid, char * ip = "169.254.1.1", 
                char * netmask = "255.255.0.0", int channel = 1, int baudrate = 9600);
        
        /**
        * Send a string to the wifi module by serial port
        *
        * @param str string to be sent
        * @param ACK string which must be acknowledge by the wifi module
        * @param res pointeur where will be stored the response from the wifi module. If res == NULL or ACK != "NO", no response is returned. (by default, res = NULL)
        *
        * @return true if ACK has been found in the response from the wifi module. False otherwise or if there is no response in 3s.
        */
        bool send(char * str, char * ACK, char * res = NULL); 
        
        /**
        * Connect the wifi module to the network.
        *
        * @return true if connected, false otherwise
        */
        bool join();
        
        /**
        * Create an adhoc network with the ssid contained in the constructor
        *
        * @return true if the network is well created, false otherwise
        */
        bool createAdhocNetwork();
        
        /**
        * Read a string
        *
        *@param str pointer where will be stored the string read
        */
        bool read(char * str);
        
        /**
        * To enter in command mode (we can configure the module)
        *
        * @return true if successful, false otherwise
        */
        bool cmdMode();
        
        /**
        * To exit the command mode
        *
        * @return true if successful, false otherwise
        */
        bool exit();
        
        /**
        * Reset the wifi module
        */
        void reset();
        
        /**
        * Check if a character is available
        *
        * @return true if a character is available, false otherwise
        */
        bool readable();
        
        /**
        * Read a character
        *
        * @return the character read
        */
        char getc();
        
        /**
        * Write a character
        *
        * @param the character which will be written
        */
        void putc(char c);
        
        /**
        * Change the baudrate of the wifi module. The modification will be effective after a reboot.
        * After a baudrate modification, you have to use the correct parameters in the Wifly constructor.
        *
        * @param baudrate new baudrate
        * @return true if the baudrate has been changed, false otherwise
        */
        bool changeBaudrate(int baudrate);
        
    private:
        Serial wifi;
        DigitalOut reset_pin;
        bool wpa;
        bool adhoc;
        bool dhcp;
        char phrase[30];
        char ssid[30];
        char ip[20];
        char netmask[20];
        int channel;
        
        char tmp_buf_rx[128];
        char buf_rx[128];
        volatile int length;
        volatile bool new_msg;
        
        void attach_rx(bool null);
        void handler_rx(void);
};

#endif