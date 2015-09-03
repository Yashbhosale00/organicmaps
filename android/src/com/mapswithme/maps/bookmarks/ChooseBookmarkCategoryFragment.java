package com.mapswithme.maps.bookmarks;

import android.app.Activity;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.Fragment;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.mapswithme.maps.R;
import com.mapswithme.maps.base.BaseMwmDialogFragment;
import com.mapswithme.maps.bookmarks.data.Bookmark;
import com.mapswithme.maps.bookmarks.data.BookmarkManager;
import com.mapswithme.maps.dialog.EditTextDialogFragment;
import com.mapswithme.util.statistics.Statistics;

import static com.mapswithme.maps.dialog.EditTextDialogFragment.OnTextSaveListener;

public class ChooseBookmarkCategoryFragment extends BaseMwmDialogFragment implements OnTextSaveListener, ChooseBookmarkCategoryAdapter.CategoryListener
{
  public static final String CATEGORY_ID = "ExtraCategoryId";
  public static final String BOOKMARK_ID = "ExtraBookmarkId";

  private Bookmark mBookmark;
  private ChooseBookmarkCategoryAdapter mAdapter;
  private RecyclerView mRecycler;


  public interface Listener
  {
    void onCategoryChanged(int bookmarkId, int newCategoryId);
  }
  private Listener mListener;

  @Override
  public void onCreate(@Nullable Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
    setStyle(DialogFragment.STYLE_NO_FRAME, R.style.MwmMain_DialogFragment);
  }

  @Nullable
  @Override
  public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
  {
    mRecycler = (RecyclerView) inflater.inflate(R.layout.recycler_default, container, false);
    mRecycler.setLayoutManager(new org.solovyev.android.views.llm.LinearLayoutManager(getActivity()));

    return mRecycler;
  }

  @Override
  public void onViewCreated(View view, Bundle savedInstanceState)
  {
    super.onViewCreated(view, savedInstanceState);

    final Bundle args = getArguments();
    final int catId = args.getInt(CATEGORY_ID, 0);
    mBookmark = BookmarkManager.INSTANCE.getBookmark(catId, args.getInt(BOOKMARK_ID));
    mAdapter = new ChooseBookmarkCategoryAdapter(getActivity(), catId);
    mAdapter.setListener(this);
    mRecycler.setAdapter(mAdapter);
  }

  @Override
  public void onAttach(Activity activity)
  {
    if (mListener == null)
    {
      final Fragment parent = getParentFragment();
      if (parent instanceof Listener)
        mListener = (Listener) parent;
      else if (activity instanceof Listener)
        mListener = (Listener) activity;
    }

    super.onAttach(activity);
  }

  @Override
  public void onSaveText(String text)
  {
    createCategory(text);
  }

  private void createCategory(String name)
  {
    final int category = BookmarkManager.INSTANCE.createCategory(name);
    mBookmark.setCategoryId(category);
    mAdapter.chooseItem(category);
    Statistics.INSTANCE.trackGroupCreated();
  }

  @Override
  public void onCategorySet(int categoryId)
  {
    mBookmark.setCategoryId(categoryId);
    mAdapter.chooseItem(categoryId);
    if (mListener != null)
      mListener.onCategoryChanged(mBookmark.getBookmarkId(), categoryId);
    dismiss();
    Statistics.INSTANCE.trackSimpleNamedEvent(Statistics.EventName.GROUP_CHANGED);
  }

  @Override
  public void onCategoryCreate()
  {
    EditTextDialogFragment.show(getString(R.string.bookmark_set_name), null,
                                getString(R.string.ok), null, this);
  }
}
