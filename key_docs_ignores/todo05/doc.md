# ChangeLog

## [1.0.1]

## [1.0.0]
Tentei fazer o todo04 em isar mas deu problema. 
todo02 não foi encontrado no console do firebase.
Resolvi criar um novo e agrupar toda experiencia nele.


# Etapas



# web
https://firebase.flutter.dev/docs/manual-installation/web/

## flutter.minSdkVersion=21
Alterações feitas em:
android/local.properties
android/app/build.gradle

## sha
catalunha@pop-os:~$ keytool -list -v \
-alias androiddebugkey -keystore ~/.android/debug.keystore
Enter keystore password:  
Alias name: androiddebugkey
Creation date: Feb 27, 2022
Entry type: PrivateKeyEntry
Certificate chain length: 1
Certificate[1]:
Owner: C=US, O=Android, CN=Android Debug
Issuer: C=US, O=Android, CN=Android Debug
Serial number: 1
Valid from: Sun Feb 27 19:58:09 BRT 2022 until: Tue Feb 20 19:58:09 BRT 2052
Certificate fingerprints:
	 SHA1: 03:1B:82:55:EA:1C:32:59:DE:40:93:5F:CE:DA:93:C5:00:79:2D:28
	 SHA256: 6A:3B:1A:F3:EC:90:0B:3A:02:94:7D:AD:FA:3C:D5:0C:B7:F8:8F:B5:0F:69:07:58:40:F2:16:28:00:02:51:C3
Signature algorithm name: SHA1withRSA (weak)
Subject Public Key Algorithm: 2048-bit RSA key
Version: 1

Warning:
The certificate uses the SHA1withRSA signature algorithm which is considered a security risk. This algorithm will be disabled in a future update.
catalunha@pop-os:~$ 


## create
flutter create --project-name=todo05 --org education.brintec --platforms android,web -a kotlin ./todo05

