*------Ejemplo para consumir un webservice--------------* 
*------Ejecutar una consulta y como resultado obtener un cursor
LOCAL loWSPrueba AS "XML Web Service"
LOCAL loException, lcErrorMsg, loWSHandler
directorio = CURDIR()
directorio = "C:\Users\raul\Desktop\timbox-vfp2\"
* Paramaetros para la conexion al webservices
url_action = "https://staging.ws.timbox.com.mx/timbrado_cfdi33/action"
usuario = "AAA010101000"
contrasena = "h6584D56fVdBbSmmnB"
archivo = directorio + "ejemplo_cfdi_33.xml"
archivo = Filetostr(archivo)

* Convertir xml a base64
xml = STRCONV(archivo, 13)

* Construir envelope
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
