//
//  TOSView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 13/03/2026.
//

import SwiftUI

struct TOSView: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 40) {
        Spacer(minLength: 16)
        
        Group {
          VStack(alignment: .leading, spacing: 0) {
            Text("Terms of Service")
              .font(.title2.bold())
            Text("Last updated: March 13, 2026")
              .font(.caption)
              .foregroundColor(.gray)
          }
        }
        
        SectionView(title: "Introduction", bodyText: "Vulputate odio turpis mattis porttitor. Risus scelerisque sit sagittis urna. At sem est aenean scelerisque velit id odio urna. Amet urna sociis sed tincidunt ut. Dui posuere mattis diam convallis nullam dictum. Morbi velit feugiat nibh viverra ornare aliquam libero. Accumsan condimentum nulla donec vel tortor. Orci nisi commodo massa at. Lobortis etiam nulla diam cursus elit id consequat ut.")
        
        SectionView(title: "Service provider", bodyText: "Nulla morbi auctor lorem tempus elementum rhoncus. Augue tortor habitant suspendisse ultricies ac feugiat amet cursus mattis.\n\nOrci nisi commodo massa at. Lobortis etiam nulla diam cursus elit id consequat ut.\n\nNeque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed qu.")
        
        SectionView(title: "Age requirements", bodyText: "Sed egestas mauris lacus dignissim aenean vel. Imperdiet eu blandit gravida elementum hendrerit felis aliquet et hac. Non mi fringilla duis in non. Mi eros a quam suspendisse. Nibh tortor tincidunt in nulla convallis hendrerit mauris eleifend.\n\nLectus eget sapien nisl egestas tincidunt nunc diam. Turpis vel ipsum vestibulum amet nibh. In nunc elementum accumsan interdum eu commodo suspendisse. Viverra egestas nisl ac porttitor. Nullam pretium duis lacus at. Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatu.")
        
        Spacer(minLength: 16)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 32)
    }
    .navigationTitle("Terms of Service")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.visible, for: .navigationBar)
  }
}

struct SectionView: View {
  let title: String
  let bodyText: String
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(title)
        .font(.system(size: 18, weight: .semibold))
        .foregroundColor(Color(.label))
      Text(bodyText)
        .font(.system(size: 14))
        .foregroundColor(Color(.label))
        .lineSpacing(4)
    }
  }
}

struct TOSView_Previews: PreviewProvider {
  static var previews: some View {
    TOSView()
  }
}
