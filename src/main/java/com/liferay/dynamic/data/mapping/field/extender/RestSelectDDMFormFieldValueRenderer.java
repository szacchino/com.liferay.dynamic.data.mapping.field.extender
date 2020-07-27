package com.liferay.dynamic.data.mapping.field.extender;

import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import com.liferay.dynamic.data.mapping.model.DDMContent;
import com.liferay.dynamic.data.mapping.model.DDMForm;
import com.liferay.dynamic.data.mapping.model.DDMFormField;
import com.liferay.dynamic.data.mapping.model.DDMFormFieldOptions;
import com.liferay.dynamic.data.mapping.model.DDMStorageLink;
import com.liferay.dynamic.data.mapping.model.Value;
import com.liferay.dynamic.data.mapping.render.BaseDDMFormFieldValueRenderer;
import com.liferay.dynamic.data.mapping.render.DDMFormFieldValueRenderer;
import com.liferay.dynamic.data.mapping.render.ValueAccessor;
import com.liferay.dynamic.data.mapping.service.DDMContentLocalServiceUtil;
import com.liferay.dynamic.data.mapping.service.DDMStorageLinkLocalServiceUtil;
import com.liferay.dynamic.data.mapping.service.persistence.DDMContentUtil;
import com.liferay.dynamic.data.mapping.storage.DDMFormFieldValue;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;

import org.osgi.service.component.annotations.Component;

/**
 * This class tells Liferay how to render the user inside the overview list. In
 * this case, the value (a screen name) is converted to the users's full name.
 * If that fails or if the screen name is null or empty,
 */
@Component(immediate = true, service = DDMFormFieldValueRenderer.class)
public class RestSelectDDMFormFieldValueRenderer extends BaseDDMFormFieldValueRenderer {

	protected ValueAccessor getValueAcessor(Locale locale) {
		return new ValueAccessor(locale) {
			public String get(DDMFormFieldValue ddmFormFieldValue) {
				Map<String, Object> properties = ddmFormFieldValue.getDDMFormField().getProperties();
				String restKey = (String) properties.get("restKey");
				// String restValue = (String) properties.get("restValue");
				if ("ddm-rest-select".equals(ddmFormFieldValue.getDDMFormField().getType())) {
					try {
						Value value = ddmFormFieldValue.getValue();
						if (value != null) {
							String contentId = value.getString(locale);
							if (!contentId.isEmpty()) {
								Long id = Long.parseLong(contentId);
								DDMContent ddmContent = DDMContentLocalServiceUtil.fetchDDMContent(id);
								if (ddmContent != null) {
									/**
									 * {"availableLanguageIds":["en_US"],"defaultLanguageId":"en_US","fieldValues":[{"instanceId":"ambx","name":"titolo","value":{"en_US":"Smart Agriculture"}}]}
									 */
									JSONObject jsonData = JSONFactoryUtil.createJSONObject(ddmContent.getData());
									String languageId = jsonData.getString("defaultLanguageId");
									String defaultLocale = Locale.getDefault().toString();
									JSONArray availableLanguageIds = jsonData.getJSONArray("availableLanguageIds");
									for (int i=0; i<availableLanguageIds.length(); ++i) {
										if (availableLanguageIds.getString(i).compareTo(defaultLocale) == 0) {
											languageId = defaultLocale;
											break;
										}
									}
									JSONArray fieldValues = jsonData.getJSONArray("fieldValues");
									for (int i = 0; i < fieldValues.length(); ++i) {
										JSONObject fieldValue = fieldValues.getJSONObject(i);
										if (fieldValue.getString("name").compareTo(restKey) == 0) {
											return fieldValue.getJSONObject("value").getString(languageId);
										}
									}
								}
							}
						}
						return "Non trovato";
					} catch (PortalException e) {
						e.printStackTrace();
						return "Non trovato";
					}
				} else {
					return "Non trovato";
				}
			}
		};
	}

	public String getSupportedDDMFormFieldType() {
		return "ddm-rest-select";
	}

	private Log _log = LogFactoryUtil.getLog(RestSelectDDMFormFieldValueRenderer.class);
}
