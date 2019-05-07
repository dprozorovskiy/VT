 /**
* @author: Dmitry Prozorovskiy
* @date: 16-Apr-19
* @description: base table compoonent
**/
({
    init: function (cmp){
        cmp.find('spinner').show();
        var headerSettings = cmp.get('v.headerSettings');
        var querySettings = cmp.get('v.querySettings');
        var filter = [];
        var search = new Object();
        headerSettings.forEach(headerItem => {
            headerItem.filterValue = null;
            if (headerItem.showFilter) {
                filter.push({field: headerItem.field, filterValue: headerItem.filterValue});
            }
        });
        if (cmp.get('v.searchField') == null || cmp.get('v.searchField') == '') {
            search.searchParams = null;
        } else {
            search.field = (cmp.get('v.searchField'));
            search.searchString = null;
        }
        querySettings[0].sortingParams = null;
        querySettings[0].filterParams = filter;
        querySettings[0].searchParams = search;
        querySettings[0].entriesOnPage = parseInt(cmp.get('v.entriesOnPage'));
        querySettings[0].currentPage = parseInt(cmp.get('v.currentPage'));
        cmp.set('v.headerSettings', headerSettings);
        cmp.set('v.querySettings', querySettings);
        cmp.set('v.queryString', JSON.stringify(cmp.get('v.querySettings')[0]));
        cmp.find('spinner').hide();
    },
    handleSearchKeyUp: function (cmp, event, helper) {
        var isEnterKey = event.keyCode;
        if (isEnterKey === 13) {
            cmp.find('spinner').show();
            helper.search(cmp, cmp.get('v.searchString'));
        }
    },
    handleSearch: function (cmp, event, helper) {
        cmp.find('spinner').show();
        helper.search(cmp, cmp.get('v.searchString'));
    },
    handleSearchChange: function (cmp, event, helper) {
        if (cmp.get('v.searchString') == '') {
            cmp.find('spinner').show();
            helper.search(cmp, cmp.get('v.searchString'));
        }
    },
    handleClearSearch: function (cmp, event, helper) {
        cmp.find('spinner').show();
        cmp.set('v.searchString', '');
        helper.search(cmp, cmp.get('v.searchString'));
    },
    handleSort: function (cmp, event, helper) {
        cmp.find('spinner').show();
        var fieldName = event.getSource().get('v.value');
        var sortingOrder  = event.getSource().get('v.name');
        helper.sort(cmp, sortingOrder, fieldName);
    },
    handleFilter: function (cmp, event, helper) {
        cmp.find('spinner').show();
        var value = event.getParam('value');
        var fieldName  = event.getSource().get('v.name');
        helper.filter(cmp, value, fieldName);
    },
    handleChangeEntriesOnPageList: function (cmp, event, helper) {
        cmp.find('spinner').show();
        var selectedValue = cmp.find('inputSelectEntriesOnPageList').get('v.value');
        helper.entriesSelect(cmp, selectedValue);
    },
    handlePreviousPage: function (cmp, event, helper) {
        cmp.find('spinner').show();
        helper.changePage(cmp, 'previous');
    },
    handleNextPage: function (cmp, event, helper) {
        cmp.find('spinner').show();
        helper.changePage(cmp, 'next');
    },
    hideSpinner: function (cmp) {
        cmp.find('spinner').hide();
    }
})