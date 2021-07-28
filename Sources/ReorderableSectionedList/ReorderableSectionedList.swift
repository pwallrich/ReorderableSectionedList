import SwiftUI
import Introspect

public struct Section<Header, Element> {
    public let header: Header
    public let elements: [Element]

    public init(header: Header, elements: [Element]) {
        self.header = header
        self.elements = elements
    }

}

struct Item<Header, Element>: Identifiable {
    enum ItemType {
        case element(Element)
        case header(Header)
    }
    let item: ItemType
    let id: Int
}

@available(iOS 13.0, *)
public class ReorderableViewModel<Header, Element>: ObservableObject {
    @Published private(set) var items: [Item<Header, Element>]

    @Published public private(set) var sections: [Section<Header, Element>]

    public init(sections: [Section<Header, Element>]) {
        self.sections = sections

        items = sections
            .flatMap { section in
                [Item<Header, Element>.ItemType.header(section.header)] + section.elements.map { Item<Header, Element>.ItemType.element($0) }
            }
            .enumerated()
            .map {
                Item(item: $0.element, id: $0.offset)
            }
    }

    func move(indices: IndexSet, newoffset: Int) {
        guard let first = items.first else { return }
        var itemsWithoutFirst = items.dropFirst()
        itemsWithoutFirst.move(fromOffsets: indices, toOffset: newoffset)
        self.items = [first] + itemsWithoutFirst

        var sections = [Section<Header, Element>]()
        var currentElements: [Element] = []
        var currentHeader: Header?
        for item in items {
            switch item.item {
            case .header(let header):
                if let cH = currentHeader {
                    let section = Section(header: cH, elements: currentElements)
                    sections.append(section)
                    currentHeader = header
                    currentElements = []
                } else {
                    currentHeader = header
                }
            case .element(let element):
                currentElements.append(element)
            }
        }
        if let currentHeader = currentHeader {
            let section = Section(header: currentHeader, elements: currentElements)
            sections.append(section)
        }

        self.sections = sections
    }
}

@available(iOS 13.0, *)
public struct ReorderableSectionedList<HeaderView: View, ElementView: View, Header, Element>: View {
    @ObservedObject var selectionViewModel: ReorderableViewModel<Header, Element>

    private let headerBuilder: (Header) -> HeaderView
    private let elementBuilder: (Element) -> ElementView
    private let listBackgroundColor: Color

    public var body: some View {
        Group {
            if #available(iOS 14.0, *) {
                list
                    .listStyle(SidebarListStyle())
            } else {
                list
                    .introspectTableView { tableView in
                        tableView.separatorStyle = .none
                        tableView.separatorColor = .clear
                    }
            }
        }
        .environment(\.editMode, .constant(.active))
    }

    var initialHeader: Header? {
        guard case .header(let header) = selectionViewModel.items.first?.item else {
            return nil
        }
        return header
    }

    var list: some View {
        List {
            // Prevent to move to first position
            if let header = initialHeader  {
                headerBuilder(header)
            }
            ForEach(selectionViewModel.items.dropFirst()) { item in
                switch item.item {
                case .header(let header):
                    headerBuilder(header)
                        .moveDisabled(true)

                case .element(let element):
                    elementBuilder(element)
                        .deleteDisabled(true)
                        .introspectTableViewCell { cell in
                            cell.shouldIndentWhileEditing = false
                        }
                }
            }
            .onDelete(perform: nil)
            .onMove(perform: selectionViewModel.move(indices:newoffset:))
            .listRowBackground(listBackgroundColor)
        }
    }

    public init(viewModel: ReorderableViewModel<Header, Element>,
                listRowBackgroundColor: Color = .clear,
                @ViewBuilder header: @escaping (Header) -> HeaderView,
                @ViewBuilder element: @escaping (Element) -> ElementView) {
        self.headerBuilder = header
        self.elementBuilder = element
        self.selectionViewModel = viewModel
        self.listBackgroundColor = listRowBackgroundColor

//        UITableViewCell.appearance()

        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
    }
}

@available(iOS 13.0, *)
struct ReorderableSectionedList_Previews: PreviewProvider {

    static var previews: some View {
//        VStack {
            ReorderableSectionedList(viewModel: .init(sections: [
                .init(header: "Aktiv", elements: ["A", "B", "C"]),
                .init(header: "Nicht Aktiv", elements: ["D", "E", "F"]),
            ]), header: {
                Text($0)
                .foregroundColor(.blue)
                .border(Color.red, width: 1)
            }, element: {
                Text($0)
                    .foregroundColor(.green)
                    .border(Color.red, width: 1)

            })
//        }
//    .background(Color.purple)
//        .preferredColorScheme(.dark)
    }
}
