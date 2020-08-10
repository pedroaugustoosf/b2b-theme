//
// Theme driven uiProperties overrides.  If you want to override elements
// of uiProperties within this file then
// 1) Uncomment the code between //OVERRIDES START HERE and
//                               //OVERRIDES END HERE
// 2) Define the specific property(ies) that you wish to
//    override from the managed package.
//
// Note that you must override according to the full object path
// but you can only override specific values, i.e. you do not need
// to provide the whole object copy.
//
// OVERRIDES START HERE

CCRZ.uiProperties = $.extend(true, CCRZ.uiProperties, {
    //     //Overriden partial objects here
  
    headerView: {
      desktop: {
        tmpl: "OSF_HeaderDesktop"
      }
    },
    myAccountHeaderView: {
      desktop: {
        tmpl: "OSF_MyAccount-Desktop"
      }
    },
    Menu: {
      desktop: {
        tmpl: "osf_MenuDesktopTemplate",
        selector: ".osf_menu_container"
      }
    }
  });
  

// OVERRIDES END HERE