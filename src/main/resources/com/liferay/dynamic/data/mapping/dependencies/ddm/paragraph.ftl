<#include "../init-ext.ftl">

<#assign style = fieldStructure.style!"" />

<p style="${escapeAttribute(style)}">
	${escape(label)}

	${fieldStructure.children}
</p>