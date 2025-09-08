# Overview 

The modular AI system is designed to efficiently route and answer user queries using a combination of FAQ, semantic search, and AI models via a customized model deployed in Databricks and serviced via a dedicated endpoint; all while maintaining strong evaluation, logging, and governance practices.

This AI Agent communicates with a developed/customed FAQ Mosaic Model in Databricks to provide tailord knolwedge-based answers as well as genenral conversations that help day-2-day business ops. 

The WebApp is the UI that deployed via Azure WebApp Service Plan and utlizing Flask Library as well as Restful Operations. It is managed, maintained, and deplopyed as IaC and via Terraform.  

