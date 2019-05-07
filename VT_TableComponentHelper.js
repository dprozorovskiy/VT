 /**
* @author: Dmitry Prozorovskiy
* @date: 16-Apr-19
* @description: base table compoonent
**/
({
    sort: function (cmp, sortingOrder, field) {
        var tableAction = cmp.get('v.tableAction');
        var sortingParams = new Object();
        var querySettings = cmp.get('v.querySettings');
        var header = cmp.get('v.headerSettings');
        sortingParams.field = field;
        if (sortingOrder === 'Both' || sortingOrder === 'DESC') {
            header.forEach((col) => {
                if (col.field === field) {
                    col.sortingOrder = 'ASC';
                } else {
                    col.sortingOrder = null;
                }
            });
            sortingParams.order = 'ASC'
        } else if (sortingOrder === 'ASC') {
            header.forEach((col) => {
                if (col.field === field) {
                    col.sortingOrder = 'DESC';
                } else {
                    col.sortingOrder = null;
                }
            });
            sortingParams.order = 'DESC'
        }
        querySettings[0].sortingParams = sortingParams;
        querySettings[0].currentPage = 1;
        cmp.set('v.currentPage', 1);
        cmp.set('v.querySettings', querySettings);
        cmp.set('v.queryString', JSON.stringify(cmp.get('v.querySettings')[0]));
        cmp.set('v.headerSettings', header);
        $A.enqueueAction(tableAction);
    },
    search: function (cmp, searchString) {
        console.log('debug');
        var tableAction = cmp.get('v.tableAction');
        var querySettings = cmp.get('v.querySettings');
        if (searchString == null || searchString == '') {
            querySettings[0].searchParams.searchString = null;
        } else {
            querySettings[0].searchParams.searchString = searchString;
        }
        querySettings[0].currentPage = 1;
        cmp.set('v.currentPage', 1);
        cmp.set('v.querySettings', querySettings);
        cmp.set('v.queryString', JSON.stringify(cmp.get('v.querySettings')[0]));
        console.log('debug2');
        $A.enqueueAction(tableAction);
    },
    filter: function (cmp, filterValue, fieldName) {
        var tableAction = cmp.get('v.tableAction');
        var querySettings = cmp.get('v.querySettings');
        var headerSettings = cmp.get('v.headerSettings');
        var filter = [];
        filterValue = JSON.parse(JSON.stringify(filterValue));
        headerSettings.forEach(headerItem => {
            if (headerItem.field == fieldName) {
                if (filterValue.length < 1) {
                    filterValue = null;
                }
                headerItem.filterValue = filterValue;
            }
            if (headerItem.showFilter) {
                filter.push({field: headerItem.field, filterValue: headerItem.filterValue});
            }
        });
        querySettings[0].filterParams = filter;
        querySettings[0].currentPage = 1;
        cmp.set('v.currentPage', 1);
        cmp.set('v.querySettings', querySettings);
        cmp.set('v.queryString', JSON.stringify(cmp.get('v.querySettings')[0]));
        $A.enqueueAction(tableAction);
    },
    entriesSelect: function (cmp, selectedValue) {
        var tableAction = cmp.get('v.tableAction');
        var querySettings = cmp.get('v.querySettings');
        querySettings[0].entriesOnPage = parseInt(selectedValue);
        querySettings[0].currentPage = 1;
        cmp.set('v.currentPage', 1);
        cmp.set('v.querySettings', querySettings);
        cmp.set('v.queryString', JSON.stringify(cmp.get('v.querySettings')[0]));
        $A.enqueueAction(tableAction);
    },
    changePage: function (cmp, target) {
        var tableAction = cmp.get('v.tableAction');
        var currentPage = cmp.get('v.currentPage');
        var querySettings = cmp.get('v.querySettings');
        if (target === 'next') {
            currentPage += 1;
        } else {
            currentPage -= 1;
        }
        querySettings[0].currentPage = currentPage;
        cmp.set('v.currentPage', currentPage);
        cmp.set('v.querySettings', querySettings);
        cmp.set('v.queryString', JSON.stringify(cmp.get('v.querySettings')[0]));
        $A.enqueueAction(tableAction);
    }
})