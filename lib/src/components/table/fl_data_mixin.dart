/*
 * Copyright 2025 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import '../../../flutter_jvx.dart';

mixin FlDataMixin {

    /// The table model
    FlTableModel get model;

    /// The data of the.
    DataChunk dataChunk = DataChunk.empty();

    /// The meta data of the.
    DalMetaData metaData = DalMetaData();

    /// The currently selected row. -1 is none selected.
    int selectedRow = -1;

    bool isDataRow(int pRowIndex) {
        return pRowIndex >= 0 && pRowIndex < dataChunk.data.length;
    }

    bool isRowDeletable(int pRowIndex) {

        return model.isEnabled &&
            isDataRow(pRowIndex) &&
            model.deleteEnabled &&
            ((selectedRow == pRowIndex && (metaData.deleteEnabled || metaData.modelDeleteEnabled)) ||
                (selectedRow != pRowIndex && metaData.modelDeleteEnabled)) &&
            (!metaData.additionalRowVisible || pRowIndex != 0) &&
            !metaData.readOnly;
    }

    bool isRowEditable(int pRowIndex) {

        if (!isDataRow(pRowIndex)) {
            return false;
        }

        if (metaData.readOnly) {
            return false;
        }

        if (selectedRow == pRowIndex) {
            if (!metaData.updateEnabled && !metaData.modelUpdateEnabled && dataChunk.getRecordStatus(pRowIndex) != RecordStatus.INSERTED) {
                return false;
            }
        } else {
            if (!metaData.modelUpdateEnabled && dataChunk.getRecordStatus(pRowIndex) != RecordStatus.INSERTED) {
                return false;
            }
        }

        return true;
    }

    bool isCellEditable(int pRowIndex, String pColumn) {
        if (!model.isEnabled) {
            return false;
        }

        ColumnDefinition? colDef = dataChunk.columnDefinitions.byName(pColumn);

        if (colDef == null) {
            return false;
        }

        if (!colDef.forcedStateless) {
            if (!isRowEditable(pRowIndex)) {
                return false;
            }

            if (!model.editable) {
                return false;
            }
        }

        if (colDef.readOnly) {
            return false;
        }

        if (dataChunk.dataReadOnly?[pRowIndex]?[dataChunk.columnDefinitions.indexByName(pColumn)] ?? false) {
            return false;
        }

        return true;
    }

}