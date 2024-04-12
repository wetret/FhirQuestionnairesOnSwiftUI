# Resource Validation against Profiles

It is possible to validate Questionnaire and QuestionnaireResponse resources against their specified profiles including code systems and value set resources:

1. Download the [HL7 FHIR validator](https://github.com/hapifhir/org.hl7.fhir.core/releases/latest/download/validator_cli.jar). 
2. Execute the validator using the following command:

   `java -jar validator_cli.jar <path-to-instance-resource> -ig <path-to-profile-resources>  -version 5.0` 
   
   The profiles should not be located in the same folder as the resource to be tested.

A complete guide on using the validator can be found on the [HL7 Confluence](https://confluence.hl7.org/display/FHIR/Using+the+FHIR+Validator#UsingtheFHIRValidator-Downloadingthevalidator).