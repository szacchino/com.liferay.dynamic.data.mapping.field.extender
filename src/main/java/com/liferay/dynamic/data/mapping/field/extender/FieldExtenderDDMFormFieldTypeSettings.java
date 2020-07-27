/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * The contents of this file are subject to the terms of the Liferay Enterprise
 * Subscription License ("License"). You may not use this file except in
 * compliance with the License. You can obtain a copy of the License by
 * contacting Liferay, Inc. See the License for the specific language governing
 * permissions and limitations under the License, including but not limited to
 * distribution rights of the Software.
 *
 *
 *
 */

package com.liferay.dynamic.data.mapping.field.extender;

import com.liferay.dynamic.data.mapping.annotations.*;
import com.liferay.dynamic.data.mapping.form.field.type.DDMFormFieldTypeSettings;
import com.liferay.dynamic.data.mapping.model.DDMFormFieldValidation;
import com.liferay.dynamic.data.mapping.model.LocalizedValue;
import com.liferay.portal.kernel.util.StringPool;

/**
 * This TypeSettings class extends the default typesettings with custom DDM field attribute definitions.
 */
@DDMForm
@DDMFormLayout(
		{
				@DDMFormLayoutPage(
						title = "basic",
						value = {
								@DDMFormLayoutRow(
										{
												@DDMFormLayoutColumn(
														size = 12,
														value =
																{"label", "predefinedValue", "required", "tip"}
												)
										}
								)
						}
				),
				@DDMFormLayoutPage(
						title = "advanced",
						value = {
								@DDMFormLayoutRow(
										{
												@DDMFormLayoutColumn(
														size = 12,
														value = {
																"repeatable", "showLabel", "validation",
																"visibilityExpression"
														}
												)
										}
								)
						}
				)
		}
)
public interface FieldExtenderDDMFormFieldTypeSettings extends DDMFormFieldTypeSettings {

	@DDMFormField(visibilityExpression = "FALSE")
	public String fieldNamespace();

	@DDMFormField(
			label = "%indexable",
			optionLabels = {
					"%not-indexable", "%indexable-keyword", "%indexable-text"
			},
			optionValues = {StringPool.BLANK, "keyword", "text"}, type = "select",
			visibilityExpression = "TRUE"
	)
	public String indexType();

	@DDMFormField(
			label = "%label",
			properties = {
					"placeholder=%enter-a-field-label",
					"tooltip=%enter-a-descriptive-field-label-that-guides-users-to-enter-the-information-you-want"
			},
			required = true, type = "key-value"
	)
	public LocalizedValue label();

	@DDMFormField(label = "%localizable", visibilityExpression = "FALSE")
	public boolean localizable();

	@DDMFormField(
			label = "%predefined-value",
			properties = {
					"placeholder=%enter-a-default-value",
					"tooltip=%enter-a-default-value-that-is-submitted-if-no-other-value-is-entered"
			},
			type = "text"
	)
	public LocalizedValue predefinedValue();

	@DDMFormField(label = "%read-only", visibilityExpression = "FALSE")
	public boolean readOnly();

	@DDMFormField(label = "%repeatable", properties = {"showAsSwitcher=true"}, visibilityExpression = "TRUE")
	public boolean repeatable();

	@DDMFormField(
			label = "%required-field", properties = {"showAsSwitcher=true"}
	)
	public boolean required();

	@DDMFormField(label = "%show-label", properties = {"showAsSwitcher=true"})
	public boolean showLabel();

	@DDMFormField(label = "%restUrl")
	public String restUrl();
	
	//TODO specificare i campi aggiuntivi
	@DDMFormField(label = "%usstyle")
	public String usstyle();
	@DDMFormField(label = "%usistab", properties = {"showAsSwitcher=true"})
	public boolean usistab();
	@DDMFormField(label = "%ustabprefix")
	public String ustabprefix();
	@DDMFormField(label = "%usistabcontainer", properties = {"showAsSwitcher=true"})
	public boolean usistabcontainer();
	@DDMFormField(label = "%usid")
	public String usid();

	@DDMFormField(label = "%restKey")
	public String restKey();

	@DDMFormField(label = "%restValue")
	public String restValue();

	@DDMFormField(
			label = "%help-text",
			properties = {
					"placeholder=%enter-help-text",
					"tooltip=%add-a-comment-to-help-users-understand-the-field-label"
			},
			type = "text"
	)
	public LocalizedValue tip();

	@DDMFormField(
			dataType = "ddm-validation", label = "%validation", type = "validation"
	)
	public DDMFormFieldValidation validation();

	/**
	 * @deprecated As of 2.0.0
	 */
	@DDMFormField(
			label = "%field-visibility-expression",
			properties = {
					"placeholder=%equals(Country, \"US\")",
					"tooltip=%write-a-conditional-expression-to-control-whether-this-field-is-displayed"
			}
	)
	@Deprecated
	public String visibilityExpression();

}