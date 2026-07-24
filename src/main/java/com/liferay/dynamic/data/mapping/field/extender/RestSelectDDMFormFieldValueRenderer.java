package com.liferay.dynamic.data.mapping.field.extender;

import java.util.Locale;

import com.liferay.dynamic.data.mapping.model.Value;
import com.liferay.dynamic.data.mapping.render.BaseDDMFormFieldValueRenderer;
import com.liferay.dynamic.data.mapping.render.DDMFormFieldValueRenderer;
import com.liferay.dynamic.data.mapping.render.ValueAccessor;
import com.liferay.dynamic.data.mapping.storage.DDMFormFieldValue;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;

import org.osgi.service.component.annotations.Component;

/**
 * This class tells Liferay how to render the ddm-rest-select value inside the overview list or article display.
 * Reads the stored JSON {"value": "...", "label": "..."} and returns the human readable label directly.
 */
@Component(immediate = true, service = DDMFormFieldValueRenderer.class)
public class RestSelectDDMFormFieldValueRenderer extends BaseDDMFormFieldValueRenderer {

	protected ValueAccessor getValueAcessor(Locale locale) {
		return new ValueAccessor(locale) {
			public String get(DDMFormFieldValue ddmFormFieldValue) {
				if ("ddm-rest-select".equals(ddmFormFieldValue.getDDMFormField().getType())) {
					try {
						Value value = ddmFormFieldValue.getValue();
						if (value != null) {
							String contentStr = value.getString(locale);
							if (contentStr != null && !contentStr.isEmpty()) {
								try {
									JSONObject json = JSONFactoryUtil.createJSONObject(contentStr);
									if (json.has("label") && !json.getString("label").isEmpty()) {
										return json.getString("label");
									} else if (json.has("value")) {
										return json.getString("value");
									}
								} catch (Exception e) {
									// Not JSON, return raw string
								}
								return contentStr;
							}
						}
						return "";
					} catch (Exception e) {
						_log.error("Error rendering rest-select field value", e);
						return "";
					}
				} else {
					return "";
				}
			}
		};
	}

	public String getSupportedDDMFormFieldType() {
		return "ddm-rest-select";
	}

	private Log _log = LogFactoryUtil.getLog(RestSelectDDMFormFieldValueRenderer.class);
}

