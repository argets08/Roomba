#include "mbed.h"
#include "Wifly.h"
#include <string>






Wifly::Wifly(   PinName tx, PinName rx, PinName _reset, char * ssid, char * phrase,
                bool wpa, char * ip, char * netmask, bool dhcp, int baudrate):
        wifi(tx, rx), reset_pin(_reset) {
    wifi.baud(baudrate);
    reset_pin = 1;
    wifi.format(8, Serial::None, 1);
    this->wpa = wpa;
    this->dhcp = dhcp;
    strcpy(this->phrase, phrase);
    strcpy(this->ssid, ssid);
    strcpy(this->ip, ip);
    strcpy(this->netmask, netmask);
    adhoc = false;
    length = 0;
    new_msg = false;
}





Wifly::Wifly(   PinName tx, PinName rx, PinName _reset, char * ssid, char * ip, char * netmask, int channel,
                int baudrate):
        wifi(tx, rx), reset_pin(_reset) {
    wifi.baud(baudrate);
    reset_pin = 1;
    wifi.format(8, Serial::None, 1);
    adhoc = true;
    strcpy(this->ssid, ssid);
    strcpy(this->ip, ip);
    strcpy(this->netmask, netmask);
    this->channel = channel;
    length = 0;
    new_msg = false;
}


void Wifly::handler_rx(void) {
    char read = wifi.getc();
    if (read != '\r' && read != '\n') {
        tmp_buf_rx[length] = read;
        length++;
        new_msg = false;
    }
    if (read == 0xff || read == '\n') {
        new_msg = true;
        tmp_buf_rx[length] = 0;
        memcpy(buf_rx, tmp_buf_rx, length);
        length = 0;
    }
}

void Wifly::attach_rx(bool null) {
    if (!null)
        wifi.attach(NULL);
    else
        wifi.attach(this, &Wifly::handler_rx);
}



bool Wifly::send(char * str, char * ACK, char * res) {

    char read;

    attach_rx(false);

    size_t found = string::npos;

    if (!strcmp(ACK, "NO"))
        wifi.printf("%s", str);
    else {

        //We flush the buffer
        while (wifi.readable())
            wifi.getc();

        Timer tmr;
        tmr.start();
        wifi.printf("%s", str);
        string checking;

        while (1) {
            if (tmr.read() > 5) {
                //We flush the buffer
                while (wifi.readable())
                    wifi.getc();

                attach_rx(true);
                return false;
            } else if (wifi.readable()) {
                read = wifi.getc();
                if ( read != '\r' && read != '\n') {
                    checking += read;
                    found = checking.find(ACK);
                    if (found != string::npos) {

                        //We flush the buffer
                        while (wifi.readable())
                            wifi.getc();

                        break;
                    }
                }
            }
        }
        attach_rx(true);
        return (found != string::npos);
    }
    if ( res != NULL) {
        int i = 0;
        while (!wifi.readable());
        wait(0.1);
        while (wifi.readable()) {
            read = wifi.getc();
            if ( read != '\r' && read != '\n') {
                res[i++] = read;
            }
        }
    }
    attach_rx(true);
    return true;
}

bool Wifly::join() {
    char cmd[30];

    exit();

    if (!cmdMode()) {
#ifdef DEBUG
        printf("join: cannot enter in cmd mode\r\n");
#endif
        exit();
        return false;
    }

    //auth
    if (!send("set w a 3\r\n", "AOK")) {
#ifdef DEBUG
        printf("join: cannot set auth\r\n");
#endif
        exit();
        return false;
    }

    //dhcp
    sprintf(cmd, "set i d %d\r\n", (dhcp) ? 1 : 0);
    if (!send(cmd, "AOK")) {
#ifdef DEBUG
        printf("join: cannot set dhcp\r\n");
#endif
        exit();
        return false;
    }

    //no echo
    if (!send("set u m 1\r\n", "AOK")) {
#ifdef DEBUG
        printf("join: cannot set no echo\r\n");
#endif
        exit();
        return false;
    }

    if (!dhcp) {
#ifdef DEBUG
        printf("not dhcp\r\n");
#endif
        sprintf(cmd, "set i a %s\r\n", ip);
        if (!send(cmd, "AOK")) {
#ifdef DEBUG
            printf("Wifly::join: cannot set ip address\r\n");
#endif
            exit();
            return false;
        }

        sprintf(cmd, "set i n %s\r\n", netmask);
        if (!send(cmd, "AOK")) {
#ifdef DEBUG
            printf("Wifly::join: cannot set netmask\r\n");
#endif
            exit();
            return false;
        }

    }

    //key step
    if (wpa)
        sprintf(cmd, "set w p %s\r\n", phrase);
    else
        sprintf(cmd, "set w k %s\r\n", phrase);

    if (!send(cmd, "AOK")) {
#ifdef DEBUG
        printf("join: cannot set phrase\r\n");
#endif
        exit();
        return false;
    }



    //join the network
    sprintf(cmd, "join %s\r\n", ssid);

    if (!send(cmd, "IP=")) {
#ifdef DEBUG
        printf("join: cannot join %s\r\n", ssid);
#endif
        exit();
        return false;
    }
    exit();
#ifdef DEBUG
    printf("\r\nssid: %s\r\nphrase: %s\r\nsecurity: %s\r\n\r\n", this->ssid, this->phrase, (wpa) ? "WPA" : "WEP");
#endif
    return true;

}



bool Wifly::createAdhocNetwork() {
    if (adhoc) {
        char cmd[50];

        exit();

        if (!cmdMode()) {
#ifdef DEBUG
            printf("Wifly::CreateAdhocNetwork: cannot enter in cmd mode\r\n");
#endif
            exit();
            return false;
        }

        if (!send("set w j 4\r\n", "AOK")) {
#ifdef DEBUG
            printf("Wifly::CreateAdhocNetwork: cannot set join 4\r\n");
#endif
            exit();
            return false;
        }

        //no echo
        if (!send("set u m 1\r\n", "AOK")) {
#ifdef DEBUG
            printf("join: cannot set no echo\r\n");
#endif
            exit();
            return false;
        }

        //ssid
        sprintf(cmd, "set w s %s\r\n", ssid);
        if (!send(cmd, "AOK")) {
#ifdef DEBUG
            printf("Wifly::CreateAdhocNetwork: cannot set ssid\r\n");
#endif
            exit();
            return false;
        }

        sprintf(cmd, "set w c %d\r\n", channel);
        if (!send(cmd, "AOK")) {
#ifdef DEBUG
            printf("Wifly::CreateAdhocNetwork: cannot set channel\r\n");
#endif
            exit();
            return false;
        }

        sprintf(cmd, "set i a %s\r\n", ip);
        if (!send(cmd, "AOK")) {
#ifdef DEBUG
            printf("Wifly::CreateAdhocNetwork: cannot set ip address\r\n");
#endif
            exit();
            return false;
        }

        sprintf(cmd, "set i n %s\r\n", netmask);
        if (!send(cmd, "AOK")) {
#ifdef DEBUG
            printf("Wifly::CreateAdhocNetwork: cannot set netmask\r\n");
#endif
            exit();
            return false;
        }

        if (!send("set i d 0\r\n", "AOK")) {
#ifdef DEBUG
            printf("Wifly::CreateAdhocNetwork: cannot set dhcp off\r\n");
#endif
            exit();
            return false;
        }

        if (!send("save\r\n", "Stor")) {
#ifdef DEBUG
            printf("Wifly::CreateAdhocNetwork: cannot save\r\n");
#endif
            exit();
            return false;
        }

        send("reboot\r\n", "NO");
#ifdef DEBUG
        printf("\r\ncreating an adhoc\r\nnetwork: %s\r\nip: %s\r\nnetmask: %s\r\nchannel: %d\r\n\r\n", ssid, ip, netmask, channel);
#endif
        return true;
    } else {
#ifdef DEBUG
        printf("Wifly::join: You don't chose the right constructor for creating an adhoc mode!\r\n");
#endif
        return false;
    }
}

bool Wifly::cmdMode() {
    if (!send("$$$", "CMD")) {
#ifdef DEBUG
        printf("Wifly::cmdMode: cannot enter in cmd mode\r\n");
#endif
        return false;
    }
    return true;
}




void Wifly::reset() {
    reset_pin = 0;
    memset(buf_rx, 0, 100);
    wait(0.2);
    reset_pin = 1;
    memset(tmp_buf_rx, 0, 100);
    wait(0.2);
}






void Wifly::putc(char c) {
    wifi.putc(c);
}




bool Wifly::read(char * str) {
    if (new_msg && str != NULL) {
        memcpy(str, buf_rx, strlen(buf_rx + 1) + 1);
        new_msg = false;
        return true;
    }
    return false;
}




bool Wifly::exit() {
    return send("exit\r", "EXIT");
}



bool Wifly::readable() {
    return(wifi.readable());
}

bool Wifly::changeBaudrate(int baudrate) {
    char cmd[20];
    exit();
    if (!cmdMode()) {
#ifdef DEBUG
        printf("Wifly::changeBaudrate: cannot enter in cmd mode\r\n");
#endif
        return false;
    }

    sprintf(cmd, "set u b %d\r\n", baudrate);
    if (!send(cmd, "AOK")) {
#ifdef DEBUG
        printf("Wifly::changeBaudrate: cannot set new baudrate\r\n");
#endif
        exit();
        return false;
    }

    if (!send("save\r\n", "Stor")) {
#ifdef DEBUG
        printf("Wifly::changeBaudrate: cannot save\r\n");
#endif
        exit();
        return false;
    }

    return true;
}


char Wifly::getc() {
    return(wifi.getc());
}