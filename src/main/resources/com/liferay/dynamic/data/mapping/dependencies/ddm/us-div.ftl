<#include "../init-ext.ftl">

<@liferay_aui["field-wrapper"]
    cssClass="form-builder-field us_css_${namespacedFieldName}"
    data=data
    helpMessage=escape(fieldStructure.tip)
    label=escape(label)
>
    <#assign inputName = portletNamespace + namespacedFieldName />
    <input type="hidden" value="" name="${inputName}" id="${inputName}">
    <h1>${fieldStructure.label}</h1>
    <p>${fieldStructure.tip}</p>
    ${fieldStructure.children}

    <script>
        $('.us_css_${namespacedFieldName}').attr('style', '${fieldStructure.usstyle}');
    </script>
</@>