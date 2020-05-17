/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global class FieldPicklist extends VisualEditor.DynamicPickList {
    VisualEditor.DesignTimePageContext context;

    global FieldPicklist(VisualEditor.DesignTimePageContext context) {
        this.context = context;
    }

    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('', '');
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {

        VisualEditor.DynamicPickListRows values = new VisualEditor.DynamicPickListRows();

        String objectName = this.context.entityName;
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);

        Schema.DescribeSObjectResult objectDescribe = sObj.getDescribe();
        Map<String, Schema.SObjectField> fields = objectDescribe.fields.getMap();
        for (Schema.SObjectField field: fields.values())
        {
            Schema.DescribeFieldResult result = field.getDescribe();
            String name = result.getName();
            String label = result.getLabel();
            Schema.DisplayType type = result.getType();
            
            if (type == Schema.DisplayType.Reference || type == Schema.DisplayType.ID || type == Schema.DisplayType.String || type == Schema.DisplayType.Email) {
                VisualEditor.DataRow value = new VisualEditor.DataRow(label, name);
                values.addRow(value);
            }
        }
        
        return values;
    }
}
