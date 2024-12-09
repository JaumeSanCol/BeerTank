#ifndef BT_HTTPS_H
#define BT_HTTPS_H

#include <WiFiClientSecure.h>

void validateToken(WiFiClientSecure& httpsclient,int tokenId);

#endif