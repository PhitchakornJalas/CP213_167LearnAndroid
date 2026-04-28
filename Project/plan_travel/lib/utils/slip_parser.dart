/// ไฟล์สำหรับแกะข้อมูลจากรหัส QR Code ของสลิปธนาคารไทย
/// ใช้รูปแบบ Tag-Length-Value (TLV) ตามมาตรฐาน EMVCo

class ThaiBankSlipData {
  final String? referenceId;
  final double? amount;
  final DateTime? transactionDate;
  final bool isValid;
  final String? rawPayload;

  ThaiBankSlipData({
    this.referenceId, 
    this.amount, 
    this.transactionDate, 
    this.isValid = false, 
    this.rawPayload,
  });
}

class SlipParser {
  /// ฟังก์ชันหลักในการแกะข้อมูลสลิปแบบโครงสร้าง (Advanced Parser)
  /// [rawPayload] คือข้อความที่ได้จากการสแกน QR Code
  static ThaiBankSlipData parseEslip(String rawPayload) {
    String payload = rawPayload.trim();
    
    // พยายามหาจุดเริ่ม EMVCo (000201)
    int startIndex = payload.indexOf("000201");
    
    // ถ้าไม่เจอ 000201 ให้เช็คว่าเป็นรูปแบบสลิปสั้น (Bank Slip QR) หรือไม่
    // รูปแบบนี้มักขึ้นต้นด้วย 00 ตามด้วยความยาว เช่น 0042...
    bool isStandardEMV = startIndex != -1;
    bool isBankSlip = !isStandardEMV && payload.startsWith("00") && payload.length > 30;

    if (!isStandardEMV && !isBankSlip) {
      return ThaiBankSlipData(isValid: false, rawPayload: payload);
    }

    if (isStandardEMV) {
      payload = payload.substring(startIndex);
    }

    Map<String, String> tags = _parseTLV(payload);

    String? refId;
    double? amount;
    DateTime? transDate;

    // 1. แกะข้อมูลจาก Tag 03 (Bill Payment / E-Slip Data)
    if (tags.containsKey("03")) {
      Map<String, String> subTags = _parseTLV(tags["03"]!);
      refId = subTags["00"]; // Transaction ID
      
      // ดึงวันเวลาโอน (มักอยู่ในรูปแบบ YYYYMMDDHHMMSS ใน Sub-tag 01)
      String? dateStr = subTags["01"];
      
      // ถ้าไม่มี Sub-tag 01 ให้ลองดูว่าใน Sub-tag 00 (Ref ID) มีวันที่นำหน้าอยู่ไหม (8 ตัวแรก)
      if (dateStr == null && refId != null && refId.length >= 8) {
        // ตรวจสอบว่า 8 หลักแรกเป็นตัวเลขทั้งหมดหรือไม่ (YYYYMMDD)
        if (RegExp(r'^\d{8}').hasMatch(refId)) {
          dateStr = refId.substring(0, 8);
        }
      }

      if (dateStr != null && dateStr.length >= 8) {
        try {
          int year = int.parse(dateStr.substring(0, 4));
          int month = int.parse(dateStr.substring(4, 6));
          int day = int.parse(dateStr.substring(6, 8));
          transDate = DateTime(year, month, day);
        } catch (_) {}
      }
    }

    // --- Fallback สำหรับ Date: ถ้ายังไม่ได้วันที่ ให้หา Pattern YYYYMMDD (ปี 20XX) ในรหัสทั้งหมด ---
    if (transDate == null) {
      // หาตัวเลข 8 หลักทั้งหมดที่ขึ้นต้นด้วย 20 (ปี 20XX)
      final dateRegExp = RegExp(r'20\d{6}'); 
      final allMatches = dateRegExp.allMatches(rawPayload);
      
      for (var match in allMatches) {
        String dateStr = match.group(0)!;
        try {
          int year = int.parse(dateStr.substring(0, 4));
          int month = int.parse(dateStr.substring(4, 6));
          int day = int.parse(dateStr.substring(6, 8));
          
          if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
            transDate = DateTime(year, month, day);
            break; // เจออันที่ใช้ได้แล้วหยุดเลย
          }
        } catch (_) {}
      }
    }

    // 2. แกะยอดเงิน (Tag 54 ใน EMVCo Standard)
    if (tags.containsKey("54")) {
      amount = double.tryParse(tags["54"]!);
    }

    // Fallback สำหรับ refId
    if (refId == null || refId.isEmpty) {
      // ถ้าเป็นรูปแบบ Bank Slip QR ให้ใช้ค่าจาก Tag 00 เป็น Ref ID
      if (tags.containsKey("00")) {
        refId = tags["00"];
      } else {
        final regExp = RegExp(r'[A-Z0-9]{15,30}');
        final match = regExp.firstMatch(payload);
        refId = match?.group(0);
      }
    }

    // --- Step สุดท้าย: ตรวจสอบความสมบูรณ์ของข้อมูล ---
    // สลิปที่ถือว่า "สมบูรณ์" ควรมีทั้ง เลขอ้างอิง และ วันที่โอน
    bool isComplete = refId != null && refId.isNotEmpty && transDate != null;

    return ThaiBankSlipData(
      referenceId: refId,
      amount: amount,
      transactionDate: transDate,
      isValid: isComplete, // ต้องครบถึงจะถือว่า Valid
      rawPayload: rawPayload,
    );
  }

  /// ฟังก์ชันช่วยแกะรหัสรูปแบบ Tag-Length-Value (TLV)
  /// โครงสร้าง: [Tag 2 หลัก][Length 2 หลัก][Value ตามความยาว Length]
  static Map<String, String> _parseTLV(String data) {
    Map<String, String> result = {};
    int i = 0;
    while (i < data.length) {
      if (i + 4 > data.length) break;
      
      // อ่าน Tag (2 หลักแรก)
      String tag = data.substring(i, i + 2);
      
      // อ่านความยาว Value (2 หลักถัดมา)
      int? length = int.tryParse(data.substring(i + 2, i + 4));
      
      if (length == null) break;
      i += 4;
      
      // อ่านค่า Value ตามความยาวที่ระบุ
      if (i + length > data.length) break;
      String value = data.substring(i, i + length);
      
      result[tag] = value;
      i += length;
    }
    return result;
  }
}
