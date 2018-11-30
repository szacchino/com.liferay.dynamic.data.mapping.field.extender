package com.liferay.dynamic.data.mapping.field.extender;

import org.osgi.service.component.annotations.Component;

import com.liferay.dynamic.data.mapping.form.field.type.DDMFormFieldType;
import com.liferay.dynamic.data.mapping.form.field.type.DDMFormFieldTypeSettings;

/**
 * This custom form field type tells Liferay to use the properties defined in FieldExtenderDDMFormFieldTypeSettings.class
 * for the custom DDM structure "ddm-users".
 */
@Component(
		immediate = true,
		property = {
				"ddm.form.field.type.name=ddm-us-div"
		},
		service = DDMFormFieldType.class
)
public class DivDDMFormFieldType implements DDMFormFieldType {

	public Class<? extends DDMFormFieldTypeSettings> getDDMFormFieldTypeSettings() {
		return FieldExtenderDDMFormFieldTypeSettings.class;
	}

	public String getName() {
		return "ddm-us-div";
	}
}
