import SwiftUI

class SBAdminVoucherViewModel: ObservableObject {
    @Published var vouchers: [VoucherModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showingCreateSheet = false
    @Published var selectedVoucher: VoucherModel? = nil
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var isSubmitting = false
    
    func loadVouchers() {
        isLoading = true
        errorMessage = nil
        
        VoucherRepository.shared.fetchAllVouchers { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let vouchers):
                    self?.vouchers = vouchers
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func deleteVoucher(_ voucher: VoucherModel) {
        isSubmitting = true
        
        VoucherRepository.shared.deleteVoucher(id: voucher.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                switch result {
                case .success:
                    self?.loadVouchers()
                    self?.selectedVoucher = nil
                case .failure(let error):
                    self?.alertTitle = "Error"
                    self?.alertMessage = error.localizedDescription
                    self?.showAlert = true
                }
            }
        }
    }
}

struct SBAdminVoucherManagement: View {
    @StateObject private var viewModel = SBAdminVoucherViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                AdminHeader(title: "Voucher Management", dismiss: dismiss)
                
                mainContent
            }
            .sheet(isPresented: $viewModel.showingCreateSheet) {
                CreateVoucherView { success in
                    if success {
                        viewModel.loadVouchers()
                    }
                }
            }
            .sheet(item: $viewModel.selectedVoucher) { voucher in
                VoucherDetailView(voucher: voucher) { success in
                    if success {
                        viewModel.loadVouchers()
                    }
                }
            }
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .overlay {
                if viewModel.isSubmitting {
                    Color.black.opacity(0.4)
                    ProgressView()
                        .tint(.white)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.loadVouchers()
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage {
            errorView(message: error)
        } else {
            voucherList
        }
    }
    
    private var voucherList: some View {
        VStack {
            List {
                ForEach(viewModel.vouchers) { voucher in
                    VoucherRow(voucher: voucher)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedVoucher = voucher
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteVoucher(voucher)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .refreshable {
                viewModel.loadVouchers()
            }
            
            createButton
        }
    }
    
    private var createButton: some View {
        Button(action: { viewModel.showingCreateSheet = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Create New Voucher")
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.main)
            .foregroundColor(.white)
            .cornerRadius(27)
            .shadow(color: Color.main.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func errorView(message: String) -> some View {
        VStack {
            Text("Error loading vouchers")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.red)
            Button("Try Again") {
                viewModel.loadVouchers()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct VoucherRow: View {
    let voucher: VoucherModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(voucher.code)
                    .font(R.font.outfitMedium.font(size: 16))
                Spacer()
                Text(voucher.formattedValue)
                    .font(R.font.outfitSemiBold.font(size: 16))
                    .foregroundColor(.main)
            }
            
            HStack {
                Text("Min Order: \(voucher.formattedMinOrderValue)")
                    .font(R.font.outfitRegular.font(size: 14))
                    .foregroundColor(.gray)
                Spacer()
                voucherStatusBadge
            }
            
            Text("Expires: \(voucher.expiryDate.formatted(date: .abbreviated, time: .shortened))")
                .font(R.font.outfitRegular.font(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
    
    private var voucherStatusBadge: some View {
        Group {
            if voucher.isDisabled {
                statusBadge(text: "Disabled", color: .red)
            } else if voucher.isExpired {
                statusBadge(text: "Expired", color: .gray)
            } else {
                statusBadge(text: "Active", color: .green)
            }
        }
    }
    
    private func statusBadge(text: String, color: Color) -> some View {
        Text(text)
            .font(R.font.outfitMedium.font(size: 12))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(4)
    }
}

struct CreateVoucherView: View {
    @Environment(\.dismiss) var dismiss
    let onComplete: (Bool) -> Void
    
    @State private var selectedType = VoucherType.fixed
    @State private var value: String = ""
    @State private var minOrderValue: String = ""
    @State private var expiryDate = Date().addingTimeInterval(7 * 24 * 60 * 60) // 7 days from now
    @State private var isDisabled = false
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Voucher Details")) {
                    Picker("Type", selection: $selectedType) {
                        Text("Fixed Amount").tag(VoucherType.fixed)
                        Text("Percentage").tag(VoucherType.percentage)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    HStack {
                        Text(selectedType == .fixed ? "$" : "")
                        TextField("Value", text: $value)
                            .keyboardType(.decimalPad)
                        if selectedType == .percentage {
                            Text("%")
                        }
                    }
                    
                    HStack {
                        Text("$")
                        TextField("Minimum Order Value", text: $minOrderValue)
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker("Expiry Date", selection: $expiryDate, in: Date()...)
                    
                    Toggle("Disabled", isOn: $isDisabled)
                }
            }
            .navigationTitle("Create Voucher")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createVoucher()
                    }
                    .disabled(isSubmitting || !isValid)
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isValid: Bool {
        guard let valueDouble = Double(value), valueDouble > 0,
              let minOrderDouble = Double(minOrderValue), minOrderDouble > 0 else {
            return false
        }
        
        if selectedType == .percentage {
            return valueDouble <= 100
        }
        
        return true
    }
    
    private func createVoucher() {
        guard let valueDouble = Double(value),
              let minOrderDouble = Double(minOrderValue) else {
            return
        }
        
        isSubmitting = true
        
        VoucherRepository.shared.createVoucher(
            type: selectedType,
            value: valueDouble,
            minOrderValue: minOrderDouble,
            expiryDate: expiryDate,
            isDisabled: isDisabled
        ) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success:
                    onComplete(true)
                    dismiss()
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}

struct VoucherDetailView: View {
    let voucher: VoucherModel
    let onComplete: (Bool) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedType: VoucherType
    @State private var value: String
    @State private var minOrderValue: String
    @State private var expiryDate: Date
    @State private var isDisabled: Bool
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showDeleteConfirmation = false
    
    init(voucher: VoucherModel, onComplete: @escaping (Bool) -> Void) {
        self.voucher = voucher
        self.onComplete = onComplete
        
        // Initialize state with voucher data
        _selectedType = State(initialValue: VoucherType(rawValue: voucher.type) ?? .fixed)
        _value = State(initialValue: String(voucher.value))
        _minOrderValue = State(initialValue: String(voucher.minOrderValue))
        _expiryDate = State(initialValue: voucher.expiryDate)
        _isDisabled = State(initialValue: voucher.isDisabled)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Voucher Information")) {
                    HStack {
                        Text("Code")
                        Spacer()
                        Text(voucher.code)
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Code")
                        Spacer()
                        Text(voucher.type)
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Voucher Details")) {
                    
                    HStack {
                        Text(selectedType == .fixed ? "$" : "")
                        TextField("Value", text: $value)
                            .keyboardType(.decimalPad)
                        if selectedType == .percentage {
                            Text("%")
                        }
                    }
                    
                    HStack {
                        Text("$")
                        TextField("Minimum Order Value", text: $minOrderValue)
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker("Expiry Date", selection: $expiryDate, in: Date()...)
                    
                    Toggle("Disabled", isOn: $isDisabled)
                }
                
                Section {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Voucher")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Voucher")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        updateVoucher()
                    }
                    .disabled(isSubmitting || !isValid)
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .confirmationDialog(
                "Are you sure you want to delete this voucher?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteVoucher()
                }
                Button("Cancel", role: .cancel) { }
            }
            .overlay {
                if isSubmitting {
                    Color.black.opacity(0.4)
                    ProgressView()
                        .tint(.white)
                }
            }
        }
    }
    
    private var isValid: Bool {
        guard let valueDouble = Double(value), valueDouble > 0,
              let minOrderDouble = Double(minOrderValue), minOrderDouble > 0 else {
            return false
        }
        
        if selectedType == .percentage {
            return valueDouble <= 100
        }
        
        return true
    }
    
    private func updateVoucher() {
        guard let valueDouble = Double(value),
              let minOrderDouble = Double(minOrderValue) else {
            return
        }
        
        isSubmitting = true
        
        VoucherRepository.shared.updateVoucher(
            id: voucher.id,
            type: selectedType,
            value: valueDouble,
            minOrderValue: minOrderDouble,
            expiryDate: expiryDate,
            isDisabled: isDisabled
        ) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success:
                    onComplete(true)
                    dismiss()
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
    
    private func deleteVoucher() {
        isSubmitting = true
        
        VoucherRepository.shared.deleteVoucher(id: voucher.id) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success:
                    onComplete(true)
                    dismiss()
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    SBAdminVoucherManagement()
} 
