<#include "../init-ext.ftl">
<#--  
    - I field-wrapper di un tab-container e dei tab in esso contenuti avranno
      la classe us_tab_prefix_ + fieldStructure.ustabprefix
    - I singoli tab sono caratterizzati dal campo fieldStructure.usistab = true.
      I rispettivi field-wrapper vengono renderizzati con la classe tabpane.
  -->
<#assign tabpane = ''>
<#if stringUtil.equals(fieldStructure.usistab, 'true')>
    <#assign tabpane = 'tab-pane original-pane'>
</#if>

<@liferay_aui["field-wrapper"]
    cssClass="form-builder-field ${tabpane} us_tab_prefix_${fieldStructure.ustabprefix} us_css_${namespacedFieldName}"
    data=data
    helpMessage=escape(fieldStructure.tip)
    label=escape(label)
>
    <#assign inputName = portletNamespace + namespacedFieldName />
    <input type="hidden" value="" name="${inputName}" id="${inputName}">
    <h1>${fieldStructure.label}</h1>
    <p>${fieldStructure.tip}</p>
    
    <div id="us_tab_${namespacedFieldName}" style="padding-left:10px; padding-right:10px;"></div>
    <#if stringUtil.equals(fieldStructure.usistabcontainer, "true") ><div id="tab_content_${fieldStructure.ustabprefix}${fieldNamespace}" class="tab-content us_tab_prefix_${fieldStructure.ustabprefix}" style="background-color: white; padding: 5px 5px 5px 5px; border-radius: 4px;"></#if>
        ${fieldStructure.children}
    <#if stringUtil.equals(fieldStructure.usistabcontainer, "true") ></div></#if>

    <script>
        <#--  
            Assegno lo stile al div più esterno  
        -->
        $('.us_css_${namespacedFieldName}').attr('style', '${fieldStructure.usstyle}');
        <#-- 
            Se ho un tab container inserisco la lista coi tab 
        -->
        <#if stringUtil.equals(fieldStructure.usistabcontainer, "true") >
            <#--  Questo script è inserito solo per il tab-container  -->
            $(document).ready(function(){
                var firstTab = $('<div class="firstTab form-builder-field tab-pane active us_tab_prefix_${fieldStructure.ustabprefix}" id="${fieldStructure.ustabprefix}${fieldStructure.name}${fieldNamespace}">');
                firstTab.appendTo($('#tab_content_${fieldStructure.ustabprefix}${fieldNamespace}'));
                $('#tab_content_${fieldStructure.ustabprefix}${fieldNamespace} > div').not('.original-pane').each(function(index, element) {
                    $('#${fieldStructure.ustabprefix}${fieldStructure.name}${fieldNamespace}').append($(element));
                });
                
                var ul = $('<ul class="nav nav-tabs">');
                ul.appendTo($('#us_tab_${namespacedFieldName}'));

                ul.append('<li class="active"><a href="#${fieldStructure.ustabprefix}${fieldStructure.name}${fieldNamespace}" data-toggle="tab">${fieldStructure.label}</a></li>');
                <#--  
                    Cerco la classe che si chiama us_tab_prefix_ tra i discendenti. 
                    In questo modo seleziono solo il livello sottostante a questo  
                -->
                $('.us_css_${namespacedFieldName}').find('.us_tab_prefix_${fieldStructure.ustabprefix} > h1').each(function(index, element) {
                    ul.append('<li><a href="#' + $(element).closest('.us_tab_prefix_${fieldStructure.ustabprefix}').attr('id') + '" data-toggle="tab">' + element.innerHTML +'</a></li>');
                });
                <#--  
                    Tra i discendenti del container cerco quelli con lo stesso prefisso  
                -->
                YUI().use( 'aui-tabview', function(Y) {
                    new Y.TabView({
                        srcNode: '.us_css_${namespacedFieldName}'
                    }).render();
                });
            })
        </#if>
        <#--  
            Se mi trovo in un tab  
        -->
        <#if stringUtil.equals(fieldStructure.usistab, "true") >
            $('.us_css_${namespacedFieldName}').attr('id', '${fieldStructure.ustabprefix}${fieldStructure.name}${fieldNamespace}')
        </#if>
    </script>
</@>