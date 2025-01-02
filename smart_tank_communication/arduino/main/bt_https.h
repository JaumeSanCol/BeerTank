#ifndef BT_HTTPS_H
#define BT_HTTPS_H

#include <WiFiClientSecure.h>

int validateToken(WiFiClientSecure& httpsclient,int tokenId);

#endif