public without sharing class osf_OrderConfirmEmailCtrl {
    public final static String ORDER_ID_KEY = 'orderId';
    public Id currentOrderId {get; set;}

    public EmailDataWrapper getcurrentOrders() {
        if(currentOrderId == null) {
            extractPageParameters();
        }
        return new EmailDataWrapper(currentOrderId);
    }

    @TestVisible
    private void extractPageParameters() {
        Map<String, String> page_parameters = ApexPages.currentPage().getParameters();
        currentOrderId = page_parameters.get(ORDER_ID_KEY);
    }

    public static String formatPrice(Decimal price) {
        Decimal rounded = price.setScale(2);
        String result = String.valueOf(rounded);
        List<String> parts = String.valueOf(rounded).split('[.]');
        if(parts.size() > 1) {
            result = Integer.valueOf(parts.get(0)).format().replaceAll('[,]', '.') + ',' + parts.get(1);
        } else {
            result = Integer.valueOf(parts.get(0)).format().replaceAll('[,]', '.') + ',00';
        }
        return result;
    }

    public class EmailDataWrapper {
        private final List<String> ORDER_QUERY_FIELDS = new List<String>{
            'Id', 'ccrz__BuyerFirstName__c', 'ccrz__BuyerLastName__c', 'ccrz__BuyerEmail__c', 'ccrz__OrderNumber__c', 'ccrz__OrderDate__c', 'ccrz__TotalAmount__c',
            'ccrz__CurrencyISOCode__c', 'ccrz__SubtotalAmount__c', 'ccrz__Storefront__c', 'ccrz__BillTo__r.ccrz__CompanyName__c', 'ccrz__BillTo__r.ccrz__AddressFirstline__c',
            'ccrz__BillTo__r.ccrz__AddressSecondline__c', 'ccrz__BillTo__r.ccrz__AddressThirdline__c', 'ccrz__BillTo__r.ccrz__City__c', 'ccrz__BillTo__r.ccrz__Country__c',
            'ccrz__BillTo__r.ccrz__PostalCode__c', 'ccrz__BillTo__r.ccrz__State__c', 'ccrz__BillTo__r.ccrz__StateISOCode__c', 'ccrz__ShipTo__r.ccrz__CompanyName__c',
            'ccrz__ShipTo__r.ccrz__AddressFirstline__c', 'ccrz__ShipTo__r.ccrz__AddressSecondline__c', 'ccrz__ShipTo__r.ccrz__AddressThirdline__c',
            'ccrz__ShipTo__r.ccrz__City__c', 'ccrz__ShipTo__r.ccrz__Country__c', 'ccrz__ShipTo__r.ccrz__PostalCode__c', 'ccrz__ShipTo__r.ccrz__State__c',
            'ccrz__ShipTo__r.ccrz__StateISOCode__c', 'ccrz__TaxAmount__c', 'ccrz__ShipAmount__c', 'ccrz__PaymentMethod__c', 'ccrz__PONumber__c', 'ccrz__ShipMethod__c',
            'ccrz__RequestDate__c', 'ccrz__OrderStatus__c', 'ccrz__ShipTo__r.ccrz__ShippingComments__c'
        };
        public String buyerFirstName {get; set;}
        public String buyerLastName {get; set;}
        public String buyerEmail {get; set;}
        public String orderNumber {get; set;}
        public String orderReference {get; set;}
        public String orderAccountReference {get; set;}
        public String orderDate {get; set;}
        public List<OrderItemWrapper> orderItems {get; set;}
        public String subTotalAmount {get; set;}
        public String totalAmount {get; set;}
        public String billingCompanyName {get; set;}
        public String billingAddressStreet {get; set;}
        public String billingAddressHouseNo {get; set;}
        public String billingAddress1 {get; set;}
        public String billingAddress2 {get; set;}
        public String billingAddress3 {get; set;}
        public String billingCity {get; set;}
        public String billingState {get; set;}
        public String billingPostalCode {get; set;}
        public String billingCountry {get; set;}
        public String shippingCompanyName {get; set;}
        public String shippingAddress1 {get; set;}
        public String shippingAddress2 {get; set;}
        public String shippingAddress3 {get; set;}
        public String taxAmount {get; set;}
        public String shippingAmount {get; set;}
        public Boolean showTaxesCost {get; set;}
        public Boolean showShippingCost {get; set;}
        public String shippingCity {get; set;}
        public String shippingState {get; set;}
        public String shippingPostalCode {get; set;}
        public String shippingCountry {get; set;}
        public String shippingLocationType {get; set;}
        public String paymentMethod {get; set;}
        public String paymentTerms {get; set;}
        public String paymentNumber {get; set;}
        public String shippMethod {get; set;}
        public String deliveryDate {get; set;}
        public String customerNo {get; set;}
        public String ordernote {get; set;}
        public String paymentConditionName {get; set;}
        public String statusName {get; set;}

        public EmailDataWrapper(Id order_id) {
            if(String.isNotBlank(order_id)) {
                String fields_string = String.join(ORDER_QUERY_FIELDS, ', ');
                String order_query = String.format('SELECT {0} FROM ccrz__E_Order__c WHERE Id = {1} LIMIT 1', new List<String>{fields_string, '\'' + String.valueOf(order_id) + '\'' });
                ccrz__E_Order__c current_order = Database.query(order_query);
                if(current_order != null) {
                    List<ccrz__E_OrderItem__c> order_item_list = [SELECT Id, ccrz__Product__r.Name, ccrz__Product__r.ccrz__SKU__c, ccrz__ParentOrderItem__c, 
                                                                      ccrz__Product__r.ccrz__ProductType__c, ccrz__Quantity__c, ccrz__Price__c, ccrz__ItemTotal__c,
                                                                      ccrz__OrderLineType__c,
                                                                      (SELECT Id, ccrz__ItemTotal__c FROM ccrz__Order_Items__r)
                                                                  FROM ccrz__E_OrderItem__c
                                                                  WHERE ccrz__Order__c = :current_order.Id
                                                                  LIMIT 50000];
                    initializeOrderItems(order_item_list);
                    this.buyerFirstName = current_order.ccrz__BuyerFirstName__c;
                    this.buyerLastName = current_order.ccrz__BuyerLastName__c;
                    this.buyerEmail = current_order.ccrz__BuyerEmail__c;
                    this.ordernote = current_order.ccrz__ShipTo__r.ccrz__ShippingComments__c;
                    this.orderNumber = String.valueOf(current_order.ccrz__OrderNumber__c);
                    this.orderDate = current_order.ccrz__OrderDate__c.day() + '/' + current_order.ccrz__OrderDate__c.month() + '/' + current_order.ccrz__OrderDate__c.year();
                    this.subTotalAmount = osf_OrderConfirmEmailCtrl.formatPrice(current_order.ccrz__SubtotalAmount__c) + ' ' + current_order.ccrz__CurrencyISOCode__c;
                    this.taxAmount = current_order.ccrz__TaxAmount__c != null ? osf_OrderConfirmEmailCtrl.formatPrice(current_order.ccrz__TaxAmount__c) + ' ' + current_order.ccrz__CurrencyISOCode__c : '';
                    this.shippingAmount = current_order.ccrz__ShipAmount__c != null ? osf_OrderConfirmEmailCtrl.formatPrice(current_order.ccrz__ShipAmount__c) + ' ' + current_order.ccrz__CurrencyISOCode__c : '';
                    this.totalAmount = osf_OrderConfirmEmailCtrl.formatPrice(current_order.ccrz__TotalAmount__c) + ' ' + current_order.ccrz__CurrencyISOCode__c;
                    if(current_order.ccrz__BillTo__c != null) {
                        initializeBillingInfo(current_order);
                    }
                    if(current_order.ccrz__ShipTo__c != null) {
                        initializeShipmentInfo(current_order);
                    }
                    if(current_order.ccrz__RequestDate__c != null) {
                        this.deliveryDate = ((Datetime) current_order.ccrz__RequestDate__c).format('yyyy/MM/dd');
                    }
                    this.paymentMethod = current_order.ccrz__PaymentMethod__c;
                    this.paymentNumber = current_order.ccrz__PONumber__c;
                    this.shippMethod = current_order.ccrz__ShipMethod__c;
                    // this.paymentConditionName = current_order.osf_Condicao_de_Pagamento__r.Name;
                    // this.statusName = osf_OrderUtility.getCCOrderStatusValueByStatusApiName(current_order.ccrz__OrderStatus__c);
                    this.showShippingCost = true;
                    this.showTaxesCost = current_order.ccrz__TaxAmount__c > 0 ? true : false;
                }
            }
        }

        private void initializeShipmentInfo(ccrz__E_Order__c current_order) {
            shippingCompanyName = current_order.ccrz__ShipTo__r.ccrz__CompanyName__c;
            shippingAddress1 = current_order.ccrz__ShipTo__r.ccrz__AddressFirstline__c;
            shippingAddress2 = String.isBlank(current_order.ccrz__ShipTo__r.ccrz__AddressSecondline__c) ? '' : current_order.ccrz__ShipTo__r.ccrz__AddressSecondline__c;
            shippingAddress3 = String.isBlank(current_order.ccrz__ShipTo__r.ccrz__AddressThirdline__c) ? '' : current_order.ccrz__ShipTo__r.ccrz__AddressThirdline__c;
            shippingCity = current_order.ccrz__ShipTo__r.ccrz__City__c;
            shippingState = String.isNotBlank(current_order.ccrz__ShipTo__r.ccrz__StateISOCode__c) ? current_order.ccrz__ShipTo__r.ccrz__State__c : current_order.ccrz__ShipTo__r.ccrz__StateISOCode__c;
            shippingPostalCode = current_order.ccrz__ShipTo__r.ccrz__PostalCode__c;
            shippingCountry = current_order.ccrz__ShipTo__r.ccrz__Country__c;
        }

        private void initializeBillingInfo(ccrz__E_Order__c current_order) {
            billingCompanyName = current_order.ccrz__BillTo__r.ccrz__CompanyName__c;
            billingAddress1 = current_order.ccrz__BillTo__r.ccrz__AddressFirstline__c;
            billingAddress2 = String.isBlank(current_order.ccrz__BillTo__r.ccrz__AddressSecondline__c) ? '' : current_order.ccrz__BillTo__r.ccrz__AddressSecondline__c;
            billingAddress3 = String.isBlank(current_order.ccrz__BillTo__r.ccrz__AddressThirdline__c) ? '' : current_order.ccrz__BillTo__r.ccrz__AddressThirdline__c;
            billingCity = current_order.ccrz__BillTo__r.ccrz__City__c;
            billingState = String.isNotBlank(current_order.ccrz__BillTo__r.ccrz__State__c) ? current_order.ccrz__BillTo__r.ccrz__State__c : current_order.ccrz__BillTo__r.ccrz__StateISOCode__c;
            billingPostalCode = current_order.ccrz__BillTo__r.ccrz__PostalCode__c;
            billingCountry = current_order.ccrz__BillTo__r.ccrz__Country__c;
        }

        private void initializeOrderItems(List<ccrz__E_OrderItem__c> order_item_list) {
            Map<Id, ccrz__E_OrderItem__c> order_item_map_result = new Map<Id, ccrz__E_OrderItem__c>();
            if(order_item_list != null && !order_item_list.isEmpty()) {
                Map<Id, ccrz__E_OrderItem__c> order_item_map = new Map<Id, ccrz__E_OrderItem__c>(order_item_list);
                for(ccrz__E_OrderItem__c order_item: order_item_list) {
                    if(order_item.ccrz__Order_Items__r.size() > 0) {
                        order_item_map_result.put(order_item.Id, order_item);
                        for(ccrz__E_OrderItem__c order_sub_item: order_item.ccrz__Order_Items__r) {
                            order_item_map_result.put(order_sub_item.Id, order_item_map.get(order_sub_item.Id));
                        }
                    } else {
                        order_item_map_result.put(order_item.Id, order_item);
                    }
                }
            }
            orderItems = new List<OrderItemWrapper>();
            for(Id key: order_item_map_result.keySet()) {
                ccrz__E_OrderItem__c oi = order_item_map_result.get(key);
                OrderItemWrapper oiw = new OrderItemWrapper();
                // oiw.productSKU = oi.ccrz__Product__r.osf_OriginalCode__c;
                oiw.productName = oi.ccrz__Product__r.Name;
                oiw.quantity = String.valueOf(oi.ccrz__Quantity__c);
                oiw.price = String.valueOf(oi.ccrz__Price__c);
                oiw.itemTotal = String.valueOf(oi.ccrz__ItemTotal__c);
                orderItems.add(oiw);
            }
        }
    }

    public class OrderItemWrapper {
        public String productName {get; set;}
        public String productSKU {get; set;}
        public String quantity {get; set;}
        public String price {get; set;}
        public String itemTotal {get; set;}
        public Boolean isMinor {get; set;}

        public OrderItemWrapper() {
            this.productName = '';
            this.productSKU = '';
            this.quantity = '';
            this.price = '';
            this.itemTotal = '';
            this.isMinor = FALSE;
        }
    }
}