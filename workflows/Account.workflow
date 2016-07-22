<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>MerchandisingEmail</fullName>
        <description>MerchandisingEmail</description>
        <protected>false</protected>
        <recipients>
            <field>PrimaryContact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Merchandising/MerchandisingEmail</template>
    </alerts>
    <fieldUpdates>
        <fullName>Send_Email</fullName>
        <field>Send_Email__c</field>
        <literalValue>0</literalValue>
        <name>Send Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Send Merchandising Email</fullName>
        <actions>
            <name>MerchandisingEmail</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Send_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Send_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
