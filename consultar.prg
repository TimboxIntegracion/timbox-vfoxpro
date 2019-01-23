*------Ejemplo para consumir un webservice--------------* 
*------Ejecutar una consulta y como resultado obtener un cursor
LOCAL loWSPrueba AS "XML Web Service"
LOCAL loException, lcErrorMsg, loWSHandler

* Parametros para la conexión al Webservice
url_action = "https://staging.ws.timbox.com.mx/cancelacion/action"
usuario = "AAA010101000"
contrasena = "h6584D56fVdBbSmmnB"

* Parametros para la consultar del CFDI
rfc_emisor  = "AAA010101AAA"
rfc_receptor = "IAD121214B34"
uuid = "69B01A54-6F7E-41F7-931D-0E3A46452BE9"
total = "1751.60"

file_cer_pem = Filetostr(directorio + "CSD01_AAA010101AAA.cer.pem")
file_key_pem = Filetostr(directorio + "CSD01_AAA010101AAA.key.pem")

* Construir envelope
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