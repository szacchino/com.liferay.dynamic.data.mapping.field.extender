<#include "../init-ext.ftl">

<@liferay_aui["field-wrapper"] cssClass="form-builder-field" data=data>
	<div class="form-group">
		<div class="input-group-container">
			<@liferay_aui.select
				cssClass="${cssClass} ${namespacedFieldName}"
				helpMessage=escape(fieldStructure.tip)
				label=escape(label)
				name=namespacedFieldName
				required=required
			>
				<option></option>
			</@liferay_aui.select>
			<button type="button" class="btn btn-default btn-sm refresh-rest-select-${namespacedFieldName}" title="Refresh" style="margin-top: 5px;">
				<i class="icon-refresh"></i> Refresh
			</button>
		</div>
	</div>
</@>

<#if fieldStructure.restUrl?? && fieldStructure.restData?? && fieldStructure.restValue?? && fieldStructure.restKey??>
	<script type="text/javascript">
		YUI().use(
			'aui-io-request',
			'node',
			'event-valuechange',
			function(Y) {
				var selectNode = Y.one('.${namespacedFieldName}');
				var refreshBtn = Y.one('.refresh-rest-select-${namespacedFieldName}');
				var rawRestUrl = '${fieldStructure.restUrl}';
				var rawRestData = {};
				try {
					var rawStr = '${escapeJS(fieldStructure.restData!("{}"))}';
					rawRestData = JSON.parse(rawStr);
				} catch(e) {
					try {
						rawRestData = JSON.parse('${fieldStructure.restData!("{}")}');
					} catch(e2) {
						console.log("Error parsing restData:", e2);
						rawRestData = {};
					}
				}
				var restKey = '${fieldStructure.restKey}';
				var restValue = '${fieldStructure.restValue}';
				var initialVal = '${escapeJS(fieldValue!)}';
				var initialObj = { value: '', label: '' };
				try {
					if (initialVal) {
						var parsed = JSON.parse(initialVal);
						if (parsed && typeof parsed === 'object' && parsed.value !== undefined) {
							initialObj = parsed;
						} else {
							initialObj = { value: String(initialVal), label: String(initialVal) };
						}
					}
				} catch(e) {
					if (initialVal) {
						initialObj = { value: String(initialVal), label: String(initialVal) };
					}
				}

				var lastRefValues = null;

				function fireChangeEvent(node) {
					if (!node) return;
					try {
						if (node.fire) {
							node.fire('change');
						}
					} catch(e) {}
					var dom = (node.getDOMNode ? node.getDOMNode() : node);
					if (dom) {
						try {
							var evt = document.createEvent('HTMLEvents');
							evt.initEvent('change', true, true);
							dom.dispatchEvent(evt);
						} catch(e) {}
					}
				}

				function getDDMFieldValue(fieldName) {
					if (!fieldName) return '';
					var wrapper = Y.one('[data-fieldname="' + fieldName + '"]') || Y.one('.field-wrapper[data-fieldname="' + fieldName + '"]');
					var inputNode = null;
					if (wrapper) {
						inputNode = wrapper.one('select, input[type="text"], textarea, input[type="radio"]:checked, input[type="checkbox"]:checked');
						if (!inputNode) {
							inputNode = wrapper.one('input[type!="hidden"]') || wrapper.one('input');
						}
					}
					if (!inputNode) {
						inputNode = Y.one('select[name*="' + fieldName + '"], input[name*="' + fieldName + '"]:checked, input[name*="' + fieldName + '"][type="text"], textarea[name*="' + fieldName + '"]');
					}
					if (!inputNode) {
						inputNode = Y.one('input[name*="' + fieldName + '"]');
					}
					if (inputNode && inputNode.getDOMNode()) {
						var dom = inputNode.getDOMNode();
						if (dom.type === 'checkbox' || dom.type === 'radio') {
							return dom.checked ? dom.value : '';
						}
						return dom.value || '';
					}
					return '';
				}

				function getDDMFieldValueProp(fieldName, prop) {
					if (!fieldName) return '';
					prop = prop || 'value';

					var rawVal = getDDMFieldValue(fieldName);
					if (!rawVal) return '';

					try {
						var obj = JSON.parse(rawVal);
						if (obj && typeof obj === 'object') {
							if (prop === 'label') {
								return (obj.label !== undefined && obj.label !== null) ? String(obj.label) : (obj.value !== undefined ? String(obj.value) : '');
							} else {
								return (obj.value !== undefined && obj.value !== null) ? String(obj.value) : rawVal;
							}
						}
					} catch(e) {}

					return rawVal;
				}

				function observeFieldChanges(fieldName, callback) {
					var wrapper = Y.one('[data-fieldname="' + fieldName + '"]') || Y.one('.field-wrapper[data-fieldname="' + fieldName + '"]');
					var nodes = [];
					if (wrapper) {
						var all = wrapper.all('select, input, textarea');
						all.each(function(n) { if (n.getDOMNode()) nodes.push(n.getDOMNode()); });
					}
					if (nodes.length === 0) {
						var globalAll = Y.all('select[name*="' + fieldName + '"], input[name*="' + fieldName + '"], textarea[name*="' + fieldName + '"]');
						globalAll.each(function(n) { if (n.getDOMNode()) nodes.push(n.getDOMNode()); });
					}

					nodes.forEach(function(dom) {
						if (!dom || dom._restSelectObserved) return;
						dom._restSelectObserved = true;

						Y.one(dom).on(['change', 'input', 'valuechange', 'blur'], callback);

						var proto = Object.getPrototypeOf(dom);
						['value', 'selectedIndex'].forEach(function(prop) {
							var descriptor = Object.getOwnPropertyDescriptor(proto, prop);
							if (!descriptor && proto) {
								descriptor = Object.getOwnPropertyDescriptor(Object.getPrototypeOf(proto), prop);
							}
							if (descriptor && descriptor.set && !dom.hasOwnProperty(prop)) {
								var originalSet = descriptor.set;
								var originalGet = descriptor.get;
								Object.defineProperty(dom, prop, {
									get: function() {
										return originalGet.call(this);
									},
									set: function(val) {
										var oldVal = originalGet.call(this);
										originalSet.call(this, val);
										if (oldVal !== val) {
											callback();
										}
									},
									configurable: true,
									enumerable: true
								});
							}
						});
					});
				}

				function resolveTemplate(templateStr, encodeURIFlag) {
					if (typeof templateStr !== 'string') return templateStr;
					var regex = /\$\{([^}]+)\}/g;
					var replaced = templateStr.replace(regex, function(match, expr) {
						var parts = expr.trim().split('.');
						var baseFieldName = parts[0];
						var prop = parts[1] || 'value';
						return getDDMFieldValueProp(baseFieldName, prop);
					});
					if (encodeURIFlag) {
						replaced = encodeURI(replaced);
					}
					return replaced;
				}

				function extractReferencedFieldsFromTemplate(templateStr) {
					var fields = [];
					if (typeof templateStr === 'string') {
						var regex = /\$\{([^}]+)\}/g;
						var match;
						while ((match = regex.exec(templateStr)) !== null) {
							if (match[1]) {
								var expr = match[1].trim();
								var baseField = expr.split('.')[0];
								fields.push(baseField);
							}
						}
					}
					return fields;
				}

				function extractReferencedFields(obj, urlStr) {
					var fields = extractReferencedFieldsFromTemplate(urlStr);
					if (typeof obj === 'object' && obj !== null) {
						for (var key in obj) {
							if (obj.hasOwnProperty(key)) {
								var item = obj[key];
								if (item && typeof item === 'object') {
									if (item.type === 'template' && typeof item.template === 'string') {
										fields = fields.concat(extractReferencedFieldsFromTemplate(item.template));
									} else {
										fields = fields.concat(extractReferencedFields(item, null));
									}
								}
							}
						}
					}
					return fields;
				}

				function resolveRestData(obj, targetUrl) {
					if (typeof obj !== 'object' || obj === null) {
						return obj;
					}
					var resolved = (obj instanceof Array) ? [] : {};
					for (var key in obj) {
						if (obj.hasOwnProperty(key)) {
							var item = obj[key];
							if (item && typeof item === 'object') {
								if (item.type === 'template' && typeof item.template === 'string') {
									resolved[key] = resolveTemplate(item.template, item.encodeURI);
								} else {
									resolved[key] = resolveRestData(item, targetUrl);
								}
							} else {
								resolved[key] = item;
							}
						}
					}
					if (typeof targetUrl === 'string' && targetUrl.startsWith('/') && window.Liferay && Liferay.authToken) {
						resolved['p_auth'] = Liferay.authToken;
					}
					return resolved;
				}

				function liferay_service(url, params, callbackfn) {
					var options = {
						credentials: "include"
					};
					var hasParams = params && Object.keys(params).length > 0;
					if (hasParams) {
						options.method = "POST";
						options.headers = {
							"Content-Type": "application/x-www-form-urlencoded"
						};
						options.body = new URLSearchParams(params);
					} else {
						options.method = "GET";
					}

					fetch(url, options)
						.then(function(response) {
							if (!response.ok) {
								throw new Error("HTTP error " + response.status);
							}
							return response.json();
						})
						.then(function(data) {
							if (callbackfn) {
								callbackfn(data);
							}
						})
						.catch(function(error) {
							console.error("Errore nella chiamata REST (" + url + "):", error);
						});
				}

				function loadOptions(keepSelected) {
					if (!selectNode) return;
					var domSelect = selectNode.getDOMNode();
					var currentDomValue = domSelect ? domSelect.value : '';
					var currentObj = { value: '', label: '' };
					try {
						if (currentDomValue) {
							var p = JSON.parse(currentDomValue);
							if (p && typeof p === 'object' && p.value !== undefined) {
								currentObj = p;
							} else {
								currentObj = { value: String(currentDomValue), label: String(currentDomValue) };
							}
						}
					} catch(e) {
						if (currentDomValue) {
							currentObj = { value: String(currentDomValue), label: String(currentDomValue) };
						}
					}

					var targetValue = keepSelected ? (currentObj.value ? currentObj.value : initialObj.value) : (initialObj.value || currentObj.value);

					var resolvedUrl = resolveTemplate(rawRestUrl, false);
					var params = resolveRestData(rawRestData, resolvedUrl);

					liferay_service(
						resolvedUrl,
						params,
						function(results) {
							if (!results) {
								results = [];
							}
							if (!Array.isArray(results)) {
								if (typeof results === 'object') {
									results = [results];
								} else {
									results = [];
								}
							}
							selectNode.empty();
							selectNode.append('<option value=""></option>');
							var foundTarget = false;
							var targetJsonVal = '';
							for (var i = 0; i < results.length; i++) {
								var itemVal = results[i][restValue];
								var itemKey = results[i][restKey];
								if (itemVal !== undefined && itemVal !== null) {
									var itemValStr = String(itemVal);
									var itemKeyStr = String(itemKey);
									var jsonVal = JSON.stringify({ value: itemValStr, label: itemKeyStr });
									var selected = (itemValStr === String(targetValue));
									if (selected) {
										foundTarget = true;
										targetJsonVal = jsonVal;
									}
									var optionNode = Y.Node.create('<option></option>');
									optionNode.setAttribute('value', jsonVal);
									optionNode.setHTML(itemKeyStr);
									if (selected) {
										optionNode.setAttribute('selected', 'selected');
									}
									selectNode.append(optionNode);
								}
							}
							if (foundTarget && targetJsonVal && domSelect) {
								domSelect.value = targetJsonVal;
							}
							fireChangeEvent(selectNode);
						}
					);
				}

				function checkReferencedFieldsChanged(forceLoad) {
					var refFields = extractReferencedFields(rawRestData, rawRestUrl);
					if (refFields.length === 0 && !forceLoad && lastRefValues !== null) {
						return;
					}
					var currentValues = {};
					var changed = (lastRefValues === null);

					for (var i = 0; i < refFields.length; i++) {
						var fName = refFields[i];
						var val = getDDMFieldValueProp(fName, 'value');
						currentValues[fName] = val;
						if (lastRefValues && lastRefValues[fName] !== val) {
							changed = true;
						}
					}

					if (changed || forceLoad) {
						lastRefValues = currentValues;
						loadOptions(true);
					}
				}

				function initRestSelect() {
					var refFields = extractReferencedFields(rawRestData, rawRestUrl);

					refFields.forEach(function(fName) {
						observeFieldChanges(fName, function() {
							checkReferencedFieldsChanged(false);
						});
					});

					checkReferencedFieldsChanged(false);

					var docNode = Y.one(document);
					if (docNode && refFields.length > 0) {
						docNode.delegate(['change', 'input', 'valuechange', 'blur', 'click'], function(e) {
							checkReferencedFieldsChanged(false);
						}, 'select, input, textarea');
					}

					if (refreshBtn) {
						refreshBtn.on('click', function(e) {
							e.preventDefault();
							loadOptions(true);
						});
					}

					if (refFields.length > 0) {
						setInterval(function() {
							refFields.forEach(function(fName) {
								observeFieldChanges(fName, function() {
									checkReferencedFieldsChanged(false);
								});
							});
							checkReferencedFieldsChanged(false);
						}, 500);
					}
				}

				Y.on('domready', function() {
					initRestSelect();
				});

				if (window.Liferay && Liferay.on) {
					Liferay.on('allPortletsReady', function() {
						checkReferencedFieldsChanged(false);
					});
				}
			}
		);
	</script>
</#if>