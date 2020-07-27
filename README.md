This fork implements a generic `div` field, named USDIV (from University of Salento, unisalento.it) that can be customized with a CSS Style attribute. 
Label and tip appears as `h1` and `p` tag in the `div`. The field allows nested fields as well: for this reason I had to include all those ftl files from Liferay source code.

Some missing properties in fieldStructure Freemarker object where added with respect to original code of Peter Mesotten.

Many thanks to Peter for his initial efforts clearly documented in https://community.liferay.com/de/blogs/-/blogs/creating-custom-ddm-field-types-in-liferay-7-x

mvn clean package && cp target/com.liferay.dynamic.data.mapping.field.extender-0.0.1-SNAPSHOT.jar /Users/zac/liferay/70ga5/deploy/