Puoi usare il comando 

```
source ~/bin/java8
```

Per attivare la versione 8 di java, necessaria allo sviluppo e alla compilazione. 

# Descrizione delle modifiche da eseguire

Il progetto presenta un campo custom `ddm-rest-select` per il DDM di Liferay 7.0.6. Nel campo è possibile definire un url di REST API di Liferay (ad esempio `/country/get-country`), scegliere le colonne value e key per realizzare un campo select nelle strutture di Liferay 7.0.6. Nel file @FieldExtenderDDMFormFieldRenderer.java, quando il campo è di tipo ddm-rest-select, si aggiungono le proprietà 'restUrl', 'restData', 'restKey', 'restValue'. La property `restData` è un oggetto JSON che consente di definire i parametri delle rest api di liferay (esempio: `{"countryId": 1}`). 
Può succedere che la REST API necessiti di un parametro che dipende da un altro campo della stessa struttura che sto definendo. Occorre quindi modificare il parsing di `restData` in modo che, se una property non ha un valore (ad esempio stringa, intero, float, data, boolean, ecc) ma ha un oggetto JSON che a sua volta è del tipo

```
{
    "type": "field",
    "fieldName": "<nome-del-campo-della-struttura>"
}
```
con `fieldName` uguale al nome che ha un altro campo della struttura, allora, il valore del parametro deve essere preso dal valore che quel campo indicato come "fieldName" ha al momento della compilazione del contenuto web. Poichè, però, liferay invoca la REST API alla prima visualizzazione della form per la compilazione del contenuto web, occorre che il campo di tipo `ddm-rest-select` si aggiorni quando i corrispondenti campi referenziati cambiano, ovvero che venga invocato nuovamente la `restUrl` con un `restData` che rifletta il valore dei campi referenziati e aggiornati; quando ciò avviene, le options del campo `ddm-rest-select` devono essere aggiornate lasciando selezionato l'elemento corrente, se quel valore è ancora presente dopo l'aggiornamento. Se pensi che non sia possibile fare l'aggiornamento automaticamente, occorre prevedere un bottone di refresh delle options, oppure un meccanismo di fire di eventi change su tutti i campi ddm, più in generale, che intercettati in particolare dal ddm-rest-select portino al refresh delle sue options.

# Aggiunta 1
Nell'utilizzo della libreria YUI, i nodi DOM ottenuti con YUI non hanno la funzione .val(); al suo posto, per ottenere il valore di un campo di una form utilizzare `.getDOMNode().value`. Ad esempio: `inputNode.getDOMNode().value`.
All'interno di `restData` devo poter definire anche altri tipi di campi dinamici, ad esempio:

```
{
    "type": "template",
    "encodeURI": true,
    "template": "bla bla ${name-of-the-field} bla bla ${name-of-another-field}"
}
```
In questo caso, la proprietà dinamica di `restData` assumerà il valore del template dopo aver sostituito il valore di tutti i campi referenziati (anche se presenti più volte). Se `encodeURI` è true il valore del template sarà codificato con la funzione js `encodeURI()` prima di essere assegnato alla proprietà dinamica. A questo punto possiamo eliminare la gestione del `"type": "field",` visto che rientra nel caso `template`. 

Nel file `src/main/resources/META-INF/resources/js/custom_fields.ext.js` sostituisci nei valori predefiniti di esempio (a partire dalla linea 1521)

```
restUrl: {
    value: 'http://localhost:8080/api/jsonws/country/get-countries'
},
restData: {
    value: JSON.stringify({
        groupId: 20152,
        plexusId: 1
    })
},
restKey: {
    value: 'name'
},
restValue: {
    value: 'a3'
},
```

con esempi di quanto specificato in questo documento. Poichè nel parametro `restData` occorre inserire una string JSON valida usa un campo fittizio `_commento_1`, `_commento_2`, `_commento_3` ecc per aggiungere commenti che spieghino il funzionamento dei vari casi dell'esempio.
