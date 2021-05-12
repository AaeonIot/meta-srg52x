#!/bin/bash

echo -e "get tpm firmware revsion"
/root/aSkCmd -getversion2

echo -e ""
echo -e "tpm2 selftest"
/root/aSkCmd -selftest2
