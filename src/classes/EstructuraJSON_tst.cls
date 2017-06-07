/********************************************************************************************************
Desarrollado por:	RTD   
Autor:              Marwin Pineda(MP)
Proyecto:           Resuelve tu Deuda
Descripción:        Clase de prueba Estructura Servicio Web.

Cambios (Versiones)
--------------------------------------------------------------------------------------------------------
    No.     Fecha               Autor                       Descripción
    ---     -----------         ------------------------    --------------------------      
    1.0     22-Oct-2016         Marwin Pineda(MP)          	Creación clase de prueba Controlador botón Envío de
    														Contrato a Cliente 
***************************************************************************************/
@isTest
private class EstructuraJSON_tst 
{
	static testMethod void testParse() 
	{
		String json = '{'+
			'	"signerProperties" : {'+
			'		"surName" : "Cortes",'+
			'		"secondSurName" : "Murcia",'+
			'		"secondName" : "Hernando",'+
			'		"firstName" : "Oscar",'+
			'		"docType" : "Cédula de Ciudadania",'+
			'		"docId" : "80121175"'+
			'	},'+
			'	"processId" : "a0W550000016EFlEAM",'+
			'	"pdfArray" : {'+
			'		"payStubDoc" : {'+
			'			"name" : "RP_3000006_24_10_2016_10_50.pdf",'+
			'			"id" : "a0X55000001X2XaEAK",'+
			'			"accessPath" : {'+
			'				"urlAccess" : "https://authenticsf.s3.amazonaws.com/RP_3000006_24_10_2016_10_50.pdf",'+
			'				"bucket" : "authenticsf"'+
			'			}'+
			'		},'+
			'		"insuranceCoverDocs" : [{'+
			'				"name" : "Contrato_Allianz_3000006_24_10_2016_10_50.pdf",'+
			'				"id" : "a0X55000001X2XVEA0",'+
			'				"accessPath" : {'+
			'					"urlAccess" : "https://authenticsf.s3.amazonaws.com/Contrato_Allianz_3000006_24_10_2016_10_50.pdf",'+
			'					"bucket" : "authenticsf"'+
			'				}'+
			'			}'+
			'		],'+
			'		"contractDocs" : [{'+
			'				"name" : "Contrato_RTD_3000006_24_10_2016_10_50.pdf",'+
			'				"id" : "a0X55000001X2XQEA0",'+
			'				"accessPath" : {'+
			'					"urlAccess" : "https://authenticsf.s3.amazonaws.com/Contrato_RTD_3000006_24_10_2016_10_50.pdf",'+
			'					"bucket" : "authenticsf"'+
			'				}'+
			'			}'+
			'		],'+
			'		"attorneyPowerDocs" : [{'+
			'				"name" : "CP_3000006_005236902_24_10_2016_10_50.pdf",'+
			'				"id" : "a0X55000001X2XfEAK",'+
			'				"accessPath" : {'+
			'					"urlAccess" : "https://authenticsf.s3.amazonaws.com/CP_3000006_005236902_24_10_2016_10_50.pdf",'+
			'					"bucket" : "authenticsf"'+
			'				}'+
			'			}, {'+
			'				"name" : "CP_3000006_8158426011_24_10_2016_10_50.pdf",'+
			'				"id" : "a0X55000001X2XkEAK",'+
			'				"accessPath" : {'+
			'					"urlAccess" : "https://authenticsf.s3.amazonaws.com/CP_3000006_8158426011_24_10_2016_10_50.pdf",'+
			'					"bucket" : "authenticsf"'+
			'				}'+
			'			}'+
			'		]'+
			'	}'+
			'}';
		EstructuraJSON obj = EstructuraJSON.parse(json);
		System.assert(obj != null);	
	}   
}