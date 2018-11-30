package com.liferay.dynamic.data.mapping.field.extender;

import java.util.Locale;

import com.liferay.dynamic.data.mapping.render.BaseDDMFormFieldValueRenderer;
import com.liferay.dynamic.data.mapping.render.DDMFormFieldValueRenderer;
import com.liferay.dynamic.data.mapping.render.ValueAccessor;
import com.liferay.dynamic.data.mapping.storage.DDMFormFieldValue;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;

import org.osgi.service.component.annotations.Component;

/**
 * This class tells Liferay how to render the user inside the overview list.
 * In this case, the value (a screen name) is converted to the users's full name.
 * If that fails or if the screen name is null or empty,
 */
@Component(immediate = true, service = DDMFormFieldValueRenderer.class)
public class DivDDMFormFieldValueRenderer extends BaseDDMFormFieldValueRenderer {

	protected ValueAccessor getValueAcessor(Locale locale) {
		return new ValueAccessor(locale) {
			public String get(DDMFormFieldValue ddmFormFieldValue) {
				_log.info("DivDDMFormFieldValueRenderer: " + ddmFormFieldValue.getDDMFormField().getType());
				if ("ddm-us-div".equals(ddmFormFieldValue.getDDMFormField().getType())) {
					return "";
				}
				return ddmFormFieldValue.getValue().getString(locale);
			}
		};
	}

	public String getSupportedDDMFormFieldType() {
		return "ddm-us-div";
	}

	private Log _log = LogFactoryUtil.getLog(DivDDMFormFieldValueRenderer.class);
}
