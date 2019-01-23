# Visual Fox Pro 9.0

Ejemplo con la integración al Webservice de Timbox

Se deberá hacer uso de las URL que hacen referencia al WSDL, en cada petición realizada:

Webservice de Timbrado:
- [Timbox Pruebas](https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl)

- [Timbox Producción](https://sistema.timbox.com.mx/timbrado_cfdi33/wsdl)

Webservice de Cancelación:

- [Timbox Pruebas](https://staging.ws.timbox.com.mx/cancelacion/wsdl)

- [Timbox Producción](https://sistema.timbox.com.mx/cancelacion/wsdl)



## Timbrar CFDI
Para hacer una petición de timbrado de un CFDI, deberá enviar las credenciales asignadas, asi como el xml que desea timbrar convertido a una cadena en base64:
```
* Paramaetros para la conexion al webservices
url_action = "https://staging.ws.timbox.com.mx/timbrado_cfdi33/action"
usuario = "AAA010101000"
contrasena = "h6584D56fVdBbSmmnB"
archivo = directorio + "ejemplo_cfdi_33.xml"
archivo = Filetostr(archivo)

* Convertir xml a base64
xml = STRCONV(archivo, 13)
```
Crear el envelope de la petición SOAP en un string:
```
set textmerge to memvar envelope on noshow 
\\ <soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:WashOut">
 \\   <soapenv:Header/>
   \\ <soapenv:Body>
     \\  <urn:timbrar_cfdi soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
       \\  <username xsi:type="xsd:string"><< usuario >></username>
        \\ <password xsi:type="xsd:string"><< contrasena >></password>
        \\ <sxml xsi:type="xsd:string"><< xml >></sxml>
    \\ </urn:timbrar_cfdi>
    \\ </soapenv:Body>
  \\ </soapenv:Envelope>
set textmerge to
set textmerge off
```

Crear un cliente y hacer el llamado al método timbrar_cfdi enviándole los parametros con la información necesaria:

```
* Crear un cliente para realizar la peticion al webservices
Release cliente 
cliente = Createobject("Msxml2.XMLHTTP")
cliente.Open("POST",url_action,.F.)
cliente.setRequestHeader("Content-type", "text/xml;charset=UTF-8")

TRY
 cliente.Send(envelope)
Catch
 wsSent=.F.
ENDTRY

IF cliente.STATUS != 200
 MESSAGEBOX("A ocurrido un error.")
ELSE
 * Obtener response
 response = cliente.ResponseText
 response = StrExtract(response ,'<xml xsi:type="xsd:string">',"</xml>")
 * Se remplaza "&lt;" por "<"
 response = STRTRAN(response , "&lt;", "<")
 * Se remplaza "&gt;" por ">"
 response = STRTRAN(response , "&gt;", ">")
 * Convertir string a UTF-8
 response = STRCONV(response , 9) 
 MESSAGEBOX(response)
 Strtofile(response, directorio + "Archivos\cfdi_timbrado.xml",0)
ENDIF
```

## Cancelar CFDI
Para la cancelación son necesarios el certificado y llave, en formato pem que corresponde al emisor del comprobante:
```
file_cer_pem = Filetostr(directorio + "CSD01_AAA010101AAA.cer.pem")
file_key_pem = Filetostr(directorio + "CSD01_AAA010101AAA.key.pem")
```
Crear el envelope para la petición de cancelación:
```
set textmerge to memvar envelope on noshow 
\\ <soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:WashOut">
  \\ <soapenv:Header/>
  \\ <soapenv:Body>
   \\ <urn:cancelar_cfdi soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    \\  <username xsi:type="xsd:string"><< usuario >></username>
     \\ <password xsi:type="xsd:string"><< contrasena >></password>
     \\ <rfc_emisor xsi:type="xsd:string"><< rfc_emisor >></rfc_emisor>
     \\ <folios xsi:type="urn:folios">
            \\ <folio xsi:type="urn:folio">
             \\  <uuid xsi:type="xsd:string"><< uuid >></uuid>
             \\  <rfc_receptor xsi:type="xsd:string"><< rfc_receptor >></rfc_receptor>
              \\ <total xsi:type="xsd:string"><< total >></total>
            \\</folio>
        \\ </folios>
        \\ <cert_pem xsi:type="xsd:string"><< file_cer_pem >></cert_pem>
        \\ <llave_pem xsi:type="xsd:string"><< file_key_pem >></llave_pem>
     \\ </urn:cancelar_cfdi>
  \\ </soapenv:Body>
set textmerge to
set textmerge off
```
Crear un cliente y hacer el llamado al método cancelar_cfdi enviándole los parametros con la información necesaria:

```
* Crear un cliente para realizar la peticion al webservices
Release cliente 
cliente = Createobject("Msxml2.XMLHTTP")
cliente.Open("POST",url_action,.F.)
cliente.setRequestHeader("Content-type", "text/xml;charset=UTF-8")

TRY
  cliente.Send(envelope)
CATCH 
  wsSent=.F.
ENDTRY

IF cliente.STATUS != 200
 MESSAGEBOX("A ocurrido un error.")
ELSE
 * Obtener response
 response = cliente.ResponseText
 MESSAGEBOX(response)
ENDIF
```


## Consultar Estatus CFDI
Para la consulta de estatus de CFDI solo es necesario generar la petición de consulta, Crear el envelope de la petición SOAP en un string:
```
set textmerge to memvar envelope on noshow 
\\ <soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:WashOut">
   \\ <soapenv:Header/>
   \\ <soapenv:Body>
    \\  <urn:consultar_estatus soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
        \\ <username xsi:type="xsd:string"><< usuario >></username>
        \\ <password xsi:type="xsd:string"><< contrasena >></password>
        \\ <uuid xsi:type="xsd:string"><< uuid >></uuid>
        \\ <rfc_emisor xsi:type="xsd:string"><< rfc_emisor >></rfc_emisor>
        \\ <rfc_receptor xsi:type="xsd:string"><< rfc_receptor >></rfc_receptor>
        \\ <total xsi:type="xsd:string"><< total >></total>
     \\ </urn:consultar_estatus>
   \\ </soapenv:Body>
\\ </soapenv:Envelope>
set textmerge to
set textmerge off
```
Crear un cliente y hacer el llamado al método consultar_estatus enviándole los parametros con la información necesaria:

```
* Crear un cliente para realizar la peticion al webservices
Release cliente 
cliente = Createobject("Msxml2.XMLHTTP")
cliente.Open("POST",url_action,.F.)
cliente.setRequestHeader("Content-type", "text/xml;charset=UTF-8")

TRY
  cliente.Send(envelope)
CATCH
  wsSent=.F.
ENDTRY

IF cliente.STATUS != 200
 MESSAGEBOX("A ocurrido un error.")
ELSE
 * Obtener response
 response = cliente.ResponseText
 MESSAGEBOX(response)
ENDIF
```

## Consultar Peticiones Pendientes
Para la consulta de peticiones pendientes son necesarios el certificado y llave, en formato pem que corresponde al receptor del comprobante:
```
file_cer_pem = Filetostr(directorio + "CSD01_AAA010101AAA.cer.pem")
file_key_pem = Filetostr(directorio + "CSD01_AAA010101AAA.key.pem")
```
Crear el envelope para la petición de consultas pendientes:
```
set textmerge to memvar envelope on noshow 
\\ <soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:WashOut">
  \\ <soapenv:Header/>
  \\ <soapenv:Body>
     \\ <urn:consultar_peticiones_pendientes soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
        \\ <username xsi:type="xsd:string"><< usuario >></username>
        \\ <password xsi:type="xsd:string"><< contrasena >></password>
        \\ <rfc_receptor xsi:type="xsd:string"><< rfc_receptor >></rfc_receptor>
        \\ <cert_pem xsi:type="xsd:string"><< file_cer_pem >></cert_pem>
        \\ <llave_pem xsi:type="xsd:string"><< file_key_pem >></llave_pem>
     \\ </urn:consultar_peticiones_pendientes>
  \\ </soapenv:Body>
\\ </soapenv:Envelope>
set textmerge to
set textmerge off
```

Crear un cliente y hacer el llamado al método consultar_peticiones_pendientes enviándole los parametros con la información necesaria:

```
* Crear un cliente para realizar la peticion al webservices
Release cliente 
cliente = Createobject("Msxml2.XMLHTTP")
cliente.Open("POST",url_action,.F.)
cliente.setRequestHeader("Content-type", "text/xml;charset=UTF-8")

TRY
  cliente.Send(envelope)
CATCH
  wsSent=.F.
ENDTRY

IF cliente.STATUS != 200
 MESSAGEBOX("A ocurrido un error.")
ELSE
 * Obtener response
 response = cliente.ResponseText
 MESSAGEBOX(response)
ENDIF
```

## Procesar Respuesta
Para realizar la petición de aceptación/rechazo de la solicitud de cancelación son necesarios el certificado y llave, en formato pem que corresponde al receptor del comprobante:
```
file_cer_pem = Filetostr(directorio + "CSD01_AAA010101AAA.cer.pem")
file_key_pem = Filetostr(directorio + "CSD01_AAA010101AAA.key.pem")
```
Crear el envelope para la petición de procesar respuestas:
```
* A(Aceptar la solicitud), R(Rechazar la solicitud)
respuesta = "A"

set textmerge to memvar envelope on noshow 
\\ <soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:WashOut">
  \\ <soapenv:Header/>
 	\\ <soapenv:Body>
     \\ <urn:procesar_respuesta soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
        \\ <username xsi:type="xsd:string"><< usuario >></username>
        \\ <password xsi:type="xsd:string"><< contrasena >></password>
        \\ <rfc_receptor xsi:type="xsd:string"><< rfc_receptor >></rfc_receptor>
        \\ <respuestas xsi:type="urn:respuestas">
           \\ <folios_respuestas xsi:type="urn:folios_respuestas">
              \\ <uuid xsi:type="xsd:string"><< uuid >></uuid>
              \\ <rfc_emisor xsi:type="xsd:string"><< rfc_emisor >></rfc_emisor>
              \\ <total xsi:type="xsd:string"><< total >></total>
              \\ <respuesta xsi:type="xsd:string"><< respuesta >></respuesta>
           \\ </folios_respuestas>
        \\ </respuestas>
        \\ <cert_pem xsi:type="xsd:string"><< file_cer_pem >></cert_pem>
        \\ <llave_pem xsi:type="xsd:string"><< file_key_pem >></llave_pem>
     \\ </urn:procesar_respuesta>
  \\ </soapenv:Body>
\\ </soapenv:Envelope>
set textmerge to
set textmerge off
```

Crear un cliente y hacer el llamado al método procesar_respuesta enviándole los parametros con la información necesaria:

```
* Crear un cliente para realizar la peticion al webservices
Release cliente 
cliente = Createobject("Msxml2.XMLHTTP")
cliente.Open("POST",url_action,.F.)
cliente.setRequestHeader("Content-type", "text/xml;charset=UTF-8")

TRY
  cliente.Send(envelope)
CATCH
  wsSent=.F.
ENDTRY

IF cliente.STATUS != 200
 MESSAGEBOX("A ocurrido un error.")
ELSE
 * Obtener response
 response = cliente.ResponseText
 MESSAGEBOX(response)
ENDIF
```

###Consultar Documentos Relacionados
Para realizar la petición de consulta de documentos relacionados son necesarios el certificado y llave, en formato pem que corresponde al receptor del comprobante:
```
file_cer_pem = Filetostr(directorio + "CSD01_AAA010101AAA.cer.pem")
file_key_pem = Filetostr(directorio + "CSD01_AAA010101AAA.key.pem")
```
Crear el envelope para la petición de consulta:
```
set textmerge to memvar envelope on noshow 
\\ <soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:WashOut">
  \\ <soapenv:Header/>
  \\ <soapenv:Body>
     \\ <urn:consultar_documento_relacionado soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
        \\ <username xsi:type="xsd:string"><< usuario >></username>
        \\ <password xsi:type="xsd:string"><< contrasena >></password>
        \\ <uuid xsi:type="xsd:string"><< uuid >></uuid>
        \\ <rfc_receptor xsi:type="xsd:string"><< rfc_receptor >></rfc_receptor>
        \\ <cert_pem xsi:type="xsd:string"><< file_cer_pem >></cert_pem>
        \\ <llave_pem xsi:type="xsd:string"><< file_key_pem >></llave_pem>
     \\ </urn:consultar_documento_relacionado>
  \\ </soapenv:Body>
\\ </soapenv:Envelope>
set textmerge to
```

Crear un cliente y hacer el llamado al método consultar_documento_relacionado enviándole los parametros con la información necesaria:

```
* Crear un cliente para realizar la peticion al webservices
Release cliente 
cliente = Createobject("Msxml2.XMLHTTP")
cliente.Open("POST",url_action,.F.)
cliente.setRequestHeader("Content-type", "text/xml;charset=UTF-8")

TRY
  cliente.Send(envelope)
CATCH
  wsSent=.F.
ENDTRY

IF cliente.STATUS != 200
 MESSAGEBOX("A ocurrido un error.")
ELSE
 * Obtener response
 response = cliente.ResponseText
 MESSAGEBOX(response)
ENDIF
```
